Task: review code based on plan

Plan:
{{plan}}

Code:
{{code}}

Yêu cầu:
- So sánh code với plan
- Tìm lỗi cụ thể (logic, thiếu step, code dư)
- Không khen chung chung

Output (JSON ONLY):

{
  "issues": [
    {
      "issue": "",
      "location": "",
      "suggestion": ""
    }
  ],
  "verdict": "APPROVE" | "NEEDS_FIX"
}