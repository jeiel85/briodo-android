#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assign priority labels (P0/P1/P2/P3) and milestone v1.2.0 to Issues #152-#251
Using milestone ID 4 (v1.2.0 - Top 10 진입 스프린트)
"""

import subprocess
import time
import sys

def assign_issue(number, priority_label, milestone_id="4"):
    """Assign priority label and milestone to an issue"""
    try:
        # Add priority label
        result = subprocess.run(
            ["gh", "issue", "edit", str(number), "--add-label", priority_label],
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        # Add milestone by ID
        result2 = subprocess.run(
            ["gh", "issue", "edit", str(number), "--milestone", milestone_id],
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        label_ok = result.returncode == 0
        milestone_ok = result2.returncode == 0
        
        if label_ok and milestone_ok:
            print(f"  ✓ Issue #{number}: {priority_label} + milestone v1.2.0")
            return True
        else:
            errors = []
            if not label_ok:
                errors.append(f"label: {result.stderr.strip()[:50]}")
            if not milestone_ok:
                errors.append(f"milestone: {result2.stderr.strip()[:50]}")
            print(f"  ✗ Issue #{number}: Failed ({', '.join(errors)})")
            return False
    except Exception as e:
        print(f"  ✗ Issue #{number}: Error: {e}")
        return False
    finally:
        time.sleep(0.3)  # Rate limiting

def main():
    print("=" * 60)
    print("Assigning priority labels and milestone to 100 Issues...")
    print("=" * 60)
    print()
    
    print("Priority mapping (from Handoff document):")
    print("  P0 (긴급/이번 주): #152-#154, #156-#168, #218-#220, #251")
    print("  P1 (높음/이번 달): #169-#198, #221-#222")
    print("  P2 (보통/다음 분기): #199-#213")
    print("  P3 (낮음/장기): #155, #214-#217, #223-#250")
    print()
    
    success = 0
    failed = 0
    
    # Process all issues in range 152-251
    for num in range(152, 252):
        priority = None
        
        # P0: UI/UX improvements
        if (152 <= num <= 154) or (156 <= num <= 168) or (218 <= num <= 220) or (num == 251):
            priority = "P0"
        # P1: Core features
        elif (169 <= num <= 198) or (221 <= num <= 222):
            priority = "P1"
        # P2: Platform + Monetization
        elif 199 <= num <= 213:
            priority = "P2"
        # P3: Performance + Security + AI + Other (including #155, #214-#217)
        elif 214 <= num <= 250:
            priority = "P3"
        elif num == 155 or num == 217:
            priority = "P3"  # Other category
        
        if priority:
            if assign_issue(num, priority):
                success += 1
            else:
                failed += 1
        else:
            print(f"  ? Issue #{num}: No priority mapped (skipping)")
            failed += 1
    
    print()
    print("=" * 60)
    print(f"Summary: {success} success, {failed} failed")
    print("=" * 60)

if __name__ == "__main__":
    main()
