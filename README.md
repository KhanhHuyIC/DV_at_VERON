# DV_at_VERON
Include design verification project that be made at VERON
##### **Phase 2 — Kế hoạch hành động ưu tiên**

###### 

###### **30 ngày (Foundation \& Architecture)**

* Chuẩn hoá UVM TB cho FIFO/Full Adder: interface + agent (drv/seqr/mon) + env + scoreboard + test.
* Viết reference model (golden behavior) cho FIFO/FA; dựng functional coverage (covergroups cho depth, flag transitions, operand spaces).
* Chuẩn hóa Makefile → scripts (Python/bash) để chạy batch regressions + sinh báo cáo cơ bản.



###### **60 ngày (Coverage‑Driven \& Quality)**

* Thêm constrained‑random sequences; khai thác SVA (protocol, handshakes, underflow/overflow).
* Đưa code/functional coverage merge vào pipeline; định nghĩa coverage goals và vòng lặp test‑plan ↔ coverage.
* Áp dụng Git flow + PR review checklist + style/lint (verible hoặc quy ước team).



###### **90 ngày (Scaling \& Collaboration)**

* Tích hợp CI (GitHub Actions/GitLab CI) cho regressions đêm/cuối tuần, xuất HTML/JUnit/coverage.Viết verification plan (1–2 trang) theo spec, map từng requirement tới tests/coverage.
* Demo nội bộ: “From OOP TB → UVM TB → Coverage Closure” kèm số liệu.
