#!/usr/bin/env python3
import json, sys, os, subprocess
from datetime import datetime

TEMPLATE = "/home/ubuntu/.openclaw/workspace/templates/quotation-modern.html"

def render(data):
    with open(TEMPLATE) as f:
        html = f.read()
    
    rows = ""
    for i, s in enumerate(data.get("services", []), 1):
        # New format: Description, Frequency, Features (bulleted list in total field)
        features = s.get('total', 'N/A').replace('\n', '<br>')
        rows += f"""    <tr>
      <td>{s['description']}</td>
      <td>{s.get('frequency','')}</td>
      <td><small>{features}</small></td>
    </tr>
"""
    note = data.get("note", "")
    if "additional_charge" in data:
        note += f"<br><b>Additional:</b> Liquid wash extra ₹{data['additional_charge']} per panel (per service)"
    
    def g(k, d=""):
        return data.get(k, d)
    
    html = html.replace("{{BUSINESS_NAME}}", g("business_name"))
    html = html.replace("{{GSTIN}}", g("gstin"))
    html = html.replace("{{MOBILE}}", g("mobile"))
    html = html.replace("{{EMAIL}}", g("email"))
    html = html.replace("{{WEBSITE}}", g("website"))
    html = html.replace("{{CUSTOMER_NAME}}", g("customer_name"))
    html = html.replace("{{CONTACT_PERSON}}", g("contact_person"))
    html = html.replace("{{CUSTOMER_MOBILE}}", g("customer_mobile"))
    html = html.replace("{{ADDRESS}}", g("address"))
    html = html.replace("{{QUOTE_NO}}", g("quote_no"))
    html = html.replace("{{QUOTE_DATE}}", g("quote_date", datetime.now().strftime("%d-%b-%Y")))
    html = html.replace("{{VALIDITY}}", g("validity", "30 Days"))
    html = html.replace("{{ROWS}}", rows)
    html = html.replace("{{NOTE_TEXT}}", note)
    html = html.replace("{{THANKYOU}}", g("thankyou", "Thank you for considering our services!"))
    html = html.replace("{{PAYMENT_TERMS}}", g("payment_terms", "Advance payment required"))
    html = html.replace("{{FOOTER_MOBILE}}", g("footer_mobile", g("mobile")))
    html = html.replace("{{FOOTER_ADDRESS}}", g("footer_address", g("address")))
    
    return html

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: gen-modern.py data.json [output.pdf]")
        sys.exit(1)
    with open(sys.argv[1]) as f:
        data = json.load(f)
    html = render(data)
    tmp = "/tmp/modern_quote.html"
    with open(tmp, "w") as f:
        f.write(html)
    out = sys.argv[2] if len(sys.argv) > 2 else "quotation-modern.pdf"
    subprocess.run(["wkhtmltopdf", "--page-size", "A4", "--margin-top", "15mm", "--margin-bottom", "15mm", "--margin-left", "15mm", "--margin-right", "15mm", tmp, out], check=True)
    print(f"✅ Generated {out}")