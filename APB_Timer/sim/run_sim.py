import subprocess
import os
import sys
import re
from tabulate import tabulate

# Required for Unicode width handling
import wcwidth  # ensures tabulate handles emoji width correctly

# ANSI colors
RED = "\033[91m"
GREEN = "\033[92m"
RESET = "\033[0m"

# Default configuration (can override via environment)
TESTNAME = os.environ.get("TESTNAME", "base_test")
TOP = os.environ.get("TOP", "testbench")
RADIX = os.environ.get("RADIX", "heximal")

LOG_FILE = f"log/{TESTNAME}.log"
WAVEFORM_FILE = f"waveform/{TESTNAME}.wlf"
FILELIST = "filelists.f"

def run_cmd(cmd, check=True):
    print(f"\nRunning: {' '.join(cmd)}")
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    if check and result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}")

def compile_design():
    run_cmd(["vlib", "work"])
    run_cmd(["vmap", "work", "work"])
    run_cmd(["vlog", "-sv", "+cover=bcesft", "-f", FILELIST])

def run_sim():
    os.makedirs("log", exist_ok=True)
    os.makedirs("waveform", exist_ok=True)

    vsim_cmd = [
        "vsim", "-debugDB",
        "-l", LOG_FILE,
        "-voptargs=+acc",
        "-assertdebug",
        "-c", TOP,
        "-wlf", WAVEFORM_FILE,
        "-do", "log -r /*; run -all; quit",
        f"+UVM_TESTNAME={TESTNAME}"
    ]
    run_cmd(vsim_cmd)
    parse_test_result(LOG_FILE)

def run_sim_with_coverage():
    """Run simulation with coverage collection enabled"""
    os.makedirs("log", exist_ok=True)
    os.makedirs("waveform", exist_ok=True)
    os.makedirs("db", exist_ok=True)
    
    coverage_db = f"db/{TESTNAME}.ucdb"
    
    vsim_cmd = [
        "vsim", "-coverage",
        "-l", LOG_FILE,
        "-c", "-voptargs=+cover=bcesft",
        "-assertdebug", TOP,
        "-wlf", WAVEFORM_FILE,
        "-do", f"coverage save -onexit {coverage_db}; log -r /*; run -all; quit",
        f"+UVM_TESTNAME={TESTNAME}"
    ]
    run_cmd(vsim_cmd)
    parse_test_result(LOG_FILE)
    return coverage_db

def run_multiple_tests_with_coverage(test_list):
    """Run multiple tests with coverage and generate final report"""
    print(f"🧪 Running {len(test_list)} tests with coverage collection...")
    
    coverage_dbs = []
    for test in test_list:
        print(f"\n{'='*50}")
        print(f"🚀 Running test: {test}")
        print(f"{'='*50}")
        
        # Set the test name for this iteration
        os.environ["TESTNAME"] = test
        global TESTNAME, LOG_FILE, WAVEFORM_FILE
        TESTNAME = test
        LOG_FILE = f"log/{TESTNAME}.log"
        WAVEFORM_FILE = f"waveform/{TESTNAME}.wlf"
        
        try:
            compile_design()
            coverage_db = run_sim_with_coverage()
            coverage_dbs.append(coverage_db)
            print(f"✅ {test} completed successfully")
        except Exception as e:
            print(f"❌ {test} failed: {e}")
            continue
    
    if coverage_dbs:
        print(f"\n📊 Generating comprehensive coverage report from {len(coverage_dbs)} tests...")
        generate_coverage_report()
    else:
        print("❌ No coverage data collected")

def generate_coverage_report():
    """Generate comprehensive coverage reports"""
    os.makedirs("coverage", exist_ok=True)
    
    print("\n🔍 Generating coverage reports...")
    
    # Merge all coverage databases
    run_cmd(["vcover", "merge", "db/merged.ucdb"] + [f"db/{f}" for f in os.listdir("db") if f.endswith(".ucdb") and f != "merged.ucdb"])
    
    # Generate summary report
    run_cmd(["vcover", "report", "db/merged.ucdb", "-output", "coverage/summary_report.txt"])
    
    # Generate detailed report
    run_cmd([
        "vcover", "report", "-zeros", "-details", "-code", "bcesft", 
        "-annotate", "-All", "-codeAll", "db/merged.ucdb", 
        "-output", "coverage/detail_report.txt"
    ])
    
    print("📊 Coverage reports generated:")
    print("  - coverage/summary_report.txt")
    print("  - coverage/detail_report.txt")
    
    # Parse and display coverage summary
    display_coverage_summary()

def display_coverage_summary():
    """Parse and display coverage summary in a nice table"""
    summary_file = "coverage/summary_report.txt"
    if not os.path.exists(summary_file):
        print("❌ Coverage summary not found")
        return
    
    try:
        with open(summary_file, 'r') as f:
            content = f.read()
        
        # Extract coverage percentages using regex
        coverage_data = []
        
        # Look for common coverage metrics
        metrics = [
            ("Statement", r"Statement\s+Coverage:\s+(\d+\.?\d*)%"),
            ("Branch", r"Branch\s+Coverage:\s+(\d+\.?\d*)%"), 
            ("Condition", r"Condition\s+Coverage:\s+(\d+\.?\d*)%"),
            ("Expression", r"Expression\s+Coverage:\s+(\d+\.?\d*)%"),
            ("Toggle", r"Toggle\s+Coverage:\s+(\d+\.?\d*)%"),
            ("FSM State", r"FSM State\s+Coverage:\s+(\d+\.?\d*)%"),
            ("FSM Trans", r"FSM Transition\s+Coverage:\s+(\d+\.?\d*)%")
        ]
        
        for metric_name, pattern in metrics:
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                percentage = float(match.group(1))
                status = "✅ Good" if percentage >= 90 else "⚠️  Medium" if percentage >= 70 else "❌ Low"
                coverage_data.append([metric_name, f"{percentage}%", status])
        
        if coverage_data:
            print("\n📈 Coverage Summary:")
            headers = ["Metric", "Coverage", "Status"]
            table = tabulate(coverage_data, headers=headers, tablefmt="heavy_outline", stralign="center")
            print(table)
        else:
            print("\n📄 Raw coverage summary:")
            print(content[:500] + "..." if len(content) > 500 else content)
            
    except Exception as e:
        print(f"❌ Error parsing coverage summary: {e}")

def parse_test_result(log_path):
    from io import StringIO
    with open(log_path, 'r') as f:
        lines = f.readlines()

    passed = False
    errors = 0
    fatals = 0
    testname = TESTNAME

    for line in lines:
        line = line.strip()
        if "+UVM_TESTNAME=" in line:
            testname = line.split('=')[-1].strip('"')
        match_error = re.match(r"UVM_ERROR\s*:\s*(\d+)", line)
        if match_error:
            errors = int(match_error.group(1))
        match_fatal = re.match(r"UVM_FATAL\s*:\s*(\d+)", line)
        if match_fatal:
            fatals = int(match_fatal.group(1))
        if "** UVM TEST PASSED **" in line or "TEST PASSED" in line:
            passed = True

    status_text = "PASS ✅" if errors == 0 and fatals == 0 else "FAIL ❌"
    color = GREEN if "PASS" in status_text else RED
    status_colored = f"{color}{status_text}{RESET}"

    # Create clean version for log file (no ANSI color)
    status_plain = "PASS ✅" if errors == 0 and fatals == 0 else "FAIL ❌"

    headers = ["Test Name", "Status", "Errors", "Fatals"]
    table_colored = [[testname, status_colored, errors, fatals]]
    table_plain = [[testname, status_plain, errors, fatals]]

    # Create string version of table (without printing)
    table_str_colored = tabulate(table_colored, headers=headers, tablefmt="heavy_outline", stralign="center", numalign="center")
    table_str_plain = tabulate(table_plain, headers=headers, tablefmt="heavy_outline", stralign="center", numalign="center")

    print("\nTest Result Summary:\n")
    print(table_str_colored)

    # Append to log file
    with open(log_path, "a") as f:
        f.write("\n# --- Result Summary Table ---\n")
        f.write(table_str_plain)
        f.write("\n")

def get_available_tests():
    """Dynamically discover available test files"""
    from pathlib import Path
    
    tests_dir = Path("../tests")
    if not tests_dir.exists():
        return []
    
    test_files = []
    for file in tests_dir.glob("*_test.sv"):
        test_name = file.stem  # Remove .sv extension
        test_files.append(test_name)
    
    return sorted(test_files)


if __name__ == "__main__":
    coverage_mode = False
    generate_report = False
    run_all_tests = False
    
    for arg in sys.argv[1:]:
        if arg == "--coverage":
            coverage_mode = True
        elif arg == "--gen-cov":
            generate_report = True
        elif arg == "--all-tests":
            run_all_tests = True
            coverage_mode = True  # Automatically enable coverage for all tests
        elif '=' in arg:
            key, value = arg.split('=', 1)
            os.environ[key] = value  # Update environment variable
    
    # Check for COV=1 environment variable
    if os.environ.get("COV") == "1":
        coverage_mode = True

    # Reload config from environment after parsing
    TESTNAME = os.environ.get("TESTNAME", "base_test")
    TOP = os.environ.get("TOP", "testbench")
    RADIX = os.environ.get("RADIX", "heximal")
    LOG_FILE = f"log/{TESTNAME}.log"
    WAVEFORM_FILE = f"waveform/{TESTNAME}.wlf"

    try:
        if generate_report:
            generate_coverage_report()
        elif run_all_tests:
            available_tests = get_available_tests()
            if available_tests:
                print(f"🎯 Found {len(available_tests)} tests: {', '.join(available_tests)}")
                run_multiple_tests_with_coverage(available_tests)
            else:
                print("❌ No test files found in ../tests directory")
        else:
            compile_design()
            if coverage_mode:
                print(f"🔍 Running {TESTNAME} with coverage collection...")
                run_sim_with_coverage()
                print(f"✅ Coverage data saved to db/{TESTNAME}.ucdb")
            else:
                run_sim()
    except Exception as e:
        print(f"{RED}❌ Error: {e}{RESET}")
        sys.exit(1)
