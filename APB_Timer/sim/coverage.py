#!/usr/bin/env python3
"""
Coverage generation helper script for APB verification
Usage examples:
  ./coverage.py --run base_test                    # Run single test with coverage
  ./coverage.py --run test1 test2 test3           # Run multiple specific tests with coverage  
  ./coverage.py --all                              # Run all available tests with coverage
  ./coverage.py --report                           # Generate coverage report from existing data
  ./coverage.py --run base_test --report          # Run test and generate report
  
Note: This script uses the Makefile's run_cov target which automatically applies exclude_coverage.tcl
"""

import subprocess
import os
import sys
from pathlib import Path

def get_available_tests():
    """Dynamically discover available test files"""
    tests_dir = Path("../tests")
    if not tests_dir.exists():
        return []
    
    test_files = []
    for file in tests_dir.glob("*_test.sv"):
        test_name = file.stem  # Remove .sv extension
        test_files.append(test_name)
    
    return sorted(test_files)

def check_exclude_coverage_file():
    """Check if exclude_coverage.tcl exists and is valid"""
    exclude_file = Path("exclude_coverage.tcl")
    
    if not exclude_file.exists():
        print("⚠️  Warning: exclude_coverage.tcl not found")
        print("   Coverage will include all code (testbench + DUT)")
        return False
    
    try:
        with open(exclude_file, 'r') as f:
            content = f.read()
            
        # Check for basic coverage exclusion commands
        if "coverage exclude" in content:
            print("✅ exclude_coverage.tcl found and contains exclusion rules")
            
            # Count exclusion rules
            exclude_count = content.count("coverage exclude")
            print(f"   Found {exclude_count} exclusion rules")
            
            # Check for common exclusions
            if "testbench" in content:
                print("   ✓ Testbench exclusion found")
            if "transaction" in content:
                print("   ✓ Transaction file exclusion found")
            if "uvm_pkg" in content:
                print("   ✓ UVM package exclusion found")
            
            return True
        else:
            print("⚠️  Warning: exclude_coverage.tcl exists but contains no exclusion rules")
            return False
            
    except Exception as e:
        print(f"❌ Error reading exclude_coverage.tcl: {e}")
        return False

def validate_environment():
    """Validate the environment before running coverage"""
    print("🔍 Validating environment...")
    
    # Check if we're in the right directory
    if not Path("Makefile").exists():
        print("❌ Error: Makefile not found. Run this script from the sim/ directory.")
        return False
    
    # Check if exclude_coverage.tcl exists
    exclude_valid = check_exclude_coverage_file()
    
    # Check if make is available
    try:
        result = subprocess.run(["make", "--version"])
        print(result)
        if result.returncode != 0:
            print("=========================================================")
            print(result.returncode)
            print("❌ Error: 'make' command not found. Make sure GNU Make is installed.")
            return False
        else:
            print("✅ GNU Make is available")
    except Exception:
        print("❌ Error: 'make' command not found. Make sure GNU Make is installed.")
        return False
    
    # Check if vsim is available (for ModelSim/QuestaSim)
    try:
        result = subprocess.run(["vsim", "-version"], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ ModelSim/QuestaSim is available")
        else:
            print("⚠️  Warning: vsim not found. Make sure ModelSim/QuestaSim is in PATH.")
    except Exception:
        print("⚠️  Warning: vsim not found. Make sure ModelSim/QuestaSim is in PATH.")
    
    return True

def run_single_test_with_coverage(testname):
    """Run a single test with coverage collection using Makefile"""
    print(f"🧪 Running {testname} with coverage...")
    print(f"   Using exclude_coverage.tcl for coverage exclusions")
    

    # Use make run_cov which automatically applies exclude_coverage.tcl
    cmd = ["make", "run_cov", f"TESTNAME={testname}"]
    
    # Run with real-time output
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
                              universal_newlines=True, cwd=os.getcwd())
    
    # Print output in real-time
    for line in process.stdout:
        print(line.rstrip())
    
    process.wait()
    
    if process.returncode == 0:
        print(f"✅ {testname} coverage collection completed successfully")
        # Check if coverage database was created
        db_file = f"db/{testname}.ucdb"
        if os.path.exists(db_file):
            print(f"📊 Coverage database created: {db_file}")
        else:
            print(f"⚠️  Warning: Coverage database not found at {db_file}")
    else:
        print(f"❌ {testname} coverage collection failed")
    
    return process.returncode == 0

def run_multiple_tests_with_coverage(test_names):
    """Run multiple tests with coverage collection"""
    print(f"🚀 Running {len(test_names)} tests with coverage collection...")
    success_count = 0
    
    for test in test_names:
        success = run_single_test_with_coverage(test)
        if success:
            success_count += 1
            print(f"✅ {test} completed successfully")
        else:
            print(f"❌ {test} failed")
    
    print(f"\n📊 Results: {success_count}/{len(test_names)} tests passed")
    return success_count == len(test_names)

def generate_coverage_report():
    """Generate coverage reports using Makefile"""
    print("📈 Generating coverage reports...")
    print("   Merging all coverage databases and generating reports...")
    
    # Check if any coverage databases exist
    db_dir = Path("db")
    if not db_dir.exists():
        print("❌ Error: No coverage database directory found. Run tests with coverage first.")
        return False
    
    ucdb_files = list(db_dir.glob("*.ucdb"))
    if not ucdb_files:
        print("❌ Error: No coverage databases found. Run tests with coverage first.")
        return False
    
    print(f"📊 Found {len(ucdb_files)} coverage databases:")
    for db in ucdb_files:
        print(f"   - {db.name}")
    
    # Use make gen_cov which generates merged coverage reports
    cmd = ["make", "gen_cov"]
    
    # Run with real-time output
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
                              universal_newlines=True, cwd=os.getcwd())
    
    # Print output in real-time
    for line in process.stdout:
        print(line.rstrip())
    
    process.wait()
    
    if process.returncode == 0:
        print("✅ Coverage reports generated successfully")
        
        # Check if coverage reports were created
        cov_dir = Path("coverage")
        if cov_dir.exists():
            report_files = list(cov_dir.glob("*"))
            if report_files:
                print("📋 Generated coverage reports:")
                for report in report_files:
                    print(f"   - {report}")
            else:
                print("⚠️  Warning: Coverage directory exists but no reports found")
        else:
            print("⚠️  Warning: Coverage directory not found")
        
        return True
    else:
        print("❌ Failed to generate coverage reports")
        return False

def merge_coverage_databases():
    """Merge all coverage databases"""
    print("🔗 Merging coverage databases...")
    
    # Check if coverage databases exist
    db_dir = Path("db")
    if not db_dir.exists():
        print("❌ Error: No coverage database directory found")
        return False
    
    ucdb_files = list(db_dir.glob("*.ucdb"))
    if len(ucdb_files) < 2:
        print(f"ℹ️  Only {len(ucdb_files)} coverage database(s) found. No merging needed.")
        return len(ucdb_files) >= 1
    
    print(f"📊 Merging {len(ucdb_files)} coverage databases...")
    
    cmd = ["make", "gen_cov"]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
                              universal_newlines=True, cwd=os.getcwd())
    
    for line in process.stdout:
        print(line.rstrip())
    
    process.wait()
    
    if process.returncode == 0:
        print("✅ Coverage databases merged successfully")
        
        # Check if merged database was created
        merged_db = Path("db/merged.ucdb")
        if merged_db.exists():
            print(f"📊 Merged coverage database: {merged_db}")
        
        return True
    else:
        print("❌ Failed to merge coverage databases")
        return False

def run_all_tests_with_coverage():
    """Run all available tests with coverage"""
    available_tests = get_available_tests()
    if not available_tests:
        print("❌ No tests found")
        return False
    
    print(f"🚀 Running all {len(available_tests)} tests with coverage...")
    success = run_multiple_tests_with_coverage(available_tests)
    
    if success:
        print("📊 All tests completed. Merging coverage...")
        merge_coverage_databases()
    
    return success

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("\nAvailable tests:")
        available_tests = get_available_tests()
        if available_tests:
            for test in available_tests:
                print(f"  - {test}")
        else:
            print("  (No test files found in ../tests)")
        print("\nUsage examples:")
        print("  python3 coverage.py --run base_test")
        print("  python3 coverage.py --run base_test onehot_test")
        print("  python3 coverage.py --all")
        print("  python3 coverage.py --report")
        sys.exit(1)
    
    run_tests = False
    generate_report = False
    run_all = False
    test_names = []
    
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--run":
            run_tests = True
            # Collect all test names until we hit another option or end
            i += 1
            while i < len(sys.argv) and not sys.argv[i].startswith("--"):
                test_names.append(sys.argv[i])
                i += 1
            i -= 1  
        elif arg == "--all":
            run_all = True
        elif arg == "--report":
            generate_report = True
        elif arg == "--help" or arg == "-h":
            print(__doc__)
            print("\nAvailable tests:")
            available_tests = get_available_tests()
            if available_tests:
                for test in available_tests:
                    print(f"  - {test}")
            else:
                print("  (No test files found in ../tests)")
            sys.exit(0)
        i += 1
    
    try:
        # Validate environment first
        if not validate_environment():
            print("❌ Environment validation failed. Please fix the issues above.")
            sys.exit(1)
        
        if run_all:
            print("🚀 Running all available tests with coverage...")
            run_all_tests_with_coverage()
        elif run_tests and test_names:
            print(f"📝 Running tests: {', '.join(test_names)}")
            success = run_multiple_tests_with_coverage(test_names)
            if success and len(test_names) > 1:
                print("📊 Merging coverage from multiple tests...")
                merge_coverage_databases()
        
        if generate_report:
            generate_coverage_report()
        
        if not any([run_tests, generate_report, run_all]):
            print("❌ No action specified. Use --help for usage.")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n⏹️  Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
