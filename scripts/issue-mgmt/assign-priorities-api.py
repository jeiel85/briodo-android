#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assign priority labels (P0/P1/P2/P3) and milestone v1.2.0 to Issues #152-#251
Using GitHub API directly (milestone ID 5)
"""

import subprocess
import time
import json
import sys

def assign_issue_api(number, priority_label, milestone_id=5):
    """Assign priority label and milestone using GitHub API"""
    try:
        # 1. Add label via API
        label_data = json.dumps({"labels": [priority_label]})
        with open(f"tmp_label_{number}.json", "w", encoding="utf-8") as f:
            f.write(label_data)
        
        result = subprocess.run(
            ["gh", "api", f"repos/jeiel85/BrioDo/issues/{number}/labels", 
             "--method", "POST", "--input", f"tmp_label_{number}.json"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        # 2. Set milestone via API
        milestone_data = json.dumps({"milestone": milestone_id})
        with open(f"tmp_milestone_{number}.json", "w", encoding="utf-8") as f:
            f.write(milestone_data)
        
        result2 = subprocess.run(
            ["gh", "api", f"repos/jeiel85/BrioDo/issues/{number}", 
             "--method", "PATCH", "--input", f"tmp_milestone_{number}.json"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10
        )
        
        # Cleanup temp files
        import os
        try:
            os.remove(f"tmp_label_{number}.json")
            os.remove(f"tmp_milestone_{number}.json")
        except:
            pass
        
        label_ok = result.returncode == 0
        milestone_ok = result2.returncode == 0
        
        if label_ok and milestone_ok:
            print(f"  ✓ Issue #{number}: {priority_label} + milestone v1.2.0")
            return True
        else:
            errors = []
            if not label_ok:
                errors.append(f"label error")
            if not milestone_ok:
                errors.append(f"milestone error")
            print(f"  ✗ Issue #{number}: Failed ({', '.join(errors)})")
            return False
    except Exception as e:
        print(f"  ✗ Issue #{number}: Error: {str(e)[:50]}")
        return False
    finally:
        time.sleep(0.3)  # Rate limiting

def main():
    print("=" * 70)
    print("Assigning priority labels and milestone to 100 Issues (via API)...")
    print("=" * 70)
    print()
    
    print("Priority mapping:")
    print("  P0 (긴급/이번 주) - UI/UX: #152-#154, #156-#168, #218-#220, #251")
    print("  P1 (높음/이번 달) - Features: #169-#198, #221-#222")
    print("  P2 (보통/다음 분기) - Platform/Monetization: #199-#213")
    print("  P3 (낮음/장기) - Performance/Security/AI/Other: #155, #214-#217, #223-#250")
    print()
    
    success = 0
    failed = 0
    
    # Process all issues in range 152-251
    for num in range(152, 252):
        priority = None
        
        # P0: UI/UX improvements (20 items)
        if (152 <= num <= 154) or (156 <= num <= 168) or (218 <= num <= 220) or (num == 251):
            priority = "P0"
        # P1: Core features (30 items)
        elif (169 <= num <= 198) or (221 <= num <= 222):
            priority = "P1"
        # P2: Platform + Monetization (15 items)
        elif 199 <= num <= 213:
            priority = "P2"
        # P3: Performance + Security + AI + Other (35 items)
        elif 214 <= num <= 250:
            priority = "P3"
        elif num == 155 or num == 217:
            priority = "P3"  # Other category
        
        if priority:
            if assign_issue_api(num, priority):
                success += 1
            else:
                failed += 1
        else:
            print(f"  ? Issue #{num}: No priority mapped (skipping)")
            failed += 1
    
    print()
    print("=" * 70)
    print(f"Summary: {success} success, {failed} failed")
    print("=" * 70)

if __name__ == "__main__":
    main()
