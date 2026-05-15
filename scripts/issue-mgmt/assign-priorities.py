#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assign priority labels (P0/P1/P2/P3) and milestone v1.2.0 to the 100 Issues (#152-#251)
"""

import subprocess
import time
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

# Define priority mapping: (start, end) -> label
priority_map = [
    # P0: Immediate (this week) - UI/UX improvements (20 issues)
    (152, 154, "P0"),
    (156, 168, "P0"),
    (218, 220, "P0"),
    (251, 251, "P0"),
    # P1: This month - Core features (30 issues)
    (169, 198, "P1"),
    (221, 222, "P1"),
    # P2: Next quarter - Platform, Monetization, Performance, Security
    (199, 216, "P2"),  # Platform + Other (except 214-216 are P2)
    (223, 235, "P2"),  # Performance
    (236, 245, "P2"),  # Security
    (209, 213, "P2"),  # Monetization
    # P3: Long term - AI enhancements
    (246, 250, "P3"),  # AI
]

def get_all_issues():
    """Get all issues in range #152-#251"""
    issues = []
    for num in range(152, 252):
        issues.append(num)
    return issues

def assign_issue(number, priority_label, milestone="v1.2.0 - Top 10 진입 스프린트"):
    """Assign priority label and milestone to an issue"""
    # Add priority label
    cmd_label = ["gh", "issue", "edit", str(number), "--add-label", priority_label]
    # Add milestone
    cmd_milestone = ["gh", "issue", "edit", str(number), "--milestone", milestone]
    
    try:
        # Add label first
        result = subprocess.run(
            cmd_label,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        # Add milestone
        result2 = subprocess.run(
            cmd_milestone,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        if result.returncode == 0 and result2.returncode == 0:
            print(f"  Issue #{number}: Added {priority_label} + milestone")
            return True
        else:
            print(f"  Issue #{number}: Failed (label: {result.stderr.strip()}, milestone: {result2.stderr.strip()})")
            return False
    except Exception as e:
        print(f"  Issue #{number}: Error: {e}")
        return False
    finally:
        time.sleep(0.3)  # Rate limiting

def main():
    print("Assigning priority labels and milestone to 100 Issues...")
    print("Priority mapping:")
    print("  P0 (긴급/이번 주): #152-#154, #156-#168, #218-#220, #251")
    print("  P1 (높음/이번 달): #169-#198, #221-#222")
    print("  P2 (보통/다음 분기): #199-#216, #223-#235, #236-#245, #209-#213")
    print("  P3 (낮음/장기): #246-#250\n")
    
    success = 0
    failed = 0
    
    # Process all issues in range 152-251
    for num in range(152, 252):
        # Determine priority for this issue
        priority = None
        
        # Check P0
        if (152 <= num <= 154) or (156 <= num <= 168) or (218 <= num <= 220) or (num == 251):
            priority = "P0"
        # Check P1
        elif (169 <= num <= 198) or (221 <= num <= 222):
            priority = "P1"
        # Check P2 (Platform, Monetization, Performance, Security, Other)
        elif (199 <= num <= 216) or (223 <= num <= 235) or (236 <= num <= 245) or (209 <= num <= 213):
            priority = "P2"
        # Check P3 (AI)
        elif 246 <= num <= 250:
            priority = "P3"
        
        if priority:
            if assign_issue(num, priority):
                success += 1
            else:
                failed += 1
        else:
            print(f"  Issue #{num}: Skipped (no priority assigned)")
            failed += 1
    
    print(f"\n=== Summary ===")
    print(f"Success: {success}")
    print(f"Failed: {failed}")
    print("=================")

if __name__ == "__main__":
    main()
