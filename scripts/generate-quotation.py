#!/usr/bin/env python3
"""
Generate a quotation PDF from template.
Usage: python3 generate-quotation.py <data.json> [output.pdf]
If no output specified, prints to stdout.
"""

import json
import sys
import os
import subprocess
from datetime import datetime

TEMPLATE = "/home/ubuntu/.openclaw/workspace/templates/quotation.html"

def render_template(data):
    with open(TEMPLATE, "r") as f:
        html = f.read()
    
    # Build service rows HTML
    rows_html = ""
    for idx, item in enumerate(data["services"], start=1):
        freq = item.get("frequency", "")
        qty = item.get("quantity", "")
        rate = item.get("rate", "")
        total = item.get("total", "N/A")
        rows_html += f"""
    <tr>
      <td>{idx}</td>
      <td>{item['description']}<br><small>{freq}</small></td>
      <td class="text-center">{qty}</td>
      <td class="text-right">{rate}</td>
      <td class="text-right">{total}</td>
    </tr>
    """
    
    # Prepare note text with additional charge if present
    note_text = data.get("note", "")
    if "additional_charge" in data:
        note_text += f"<br>Note:- If a liquid wash is required, an additional charge of ₹{data['additional_charge']} per panel will be applied (Per service)"
    
    # Substitute all placeholders
    html = html.replace("{{BUSINESS_NAME}}", data.get("business_name", ""))
    html = html.replace("{{GSTIN}}", data.get("gstin", ""))
    html = html.replace("{{MOBILE}}", data.get("mobile", ""))
    html = html.replace("{{EMAIL}}", data.get("email", ""))
    html = html.replace("{{WEBSITE}}", data.get("website", ""))
    html = html.replace("{{CUSTOMER_NAME}}", data.get("customer_name", ""))
    html = html.replace("{{CONTACT_PERSON}}", data.get("contact_person", ""))
    html = html.replace("{{CUSTOMER_MOBILE}}", data.get("customer_mobile", ""))
    html = html.replace("{{ADDRESS}}", data.get("address", ""))
    html = html.replace("{{QUOTE_NO}}", data.get("quote_no", ""))
    html = html.replace("{{QUOTE_DATE}}", data.get("quote_date", datetime.now().strftime("%d-%b-%Y")))
    html = html.replace("{{VALIDITY}}", data.get("validity", "30Days"))
    html = html.replace("{{ROWS}}", rows_html)
    html = html.replace("{{NOTE_TEXT}}", note_text)
    html = html.replace("{{THANKYOU}}", data.get("thankyou", "Thank you for considering Solar Cleaning Solutions!"))
    html = html.replace("{{PAYMENT_TERMS}}", data.get("payment_terms", "Quarterly Advance"))
    html = html.replace("{{FOOTER_MOBILE}}", data.get("footer_mobile", data.get("mobile", "")))
    html = html.replace("{{FOOTER_ADDRESS}}", data.get("footer_address", data.get("address", "")))
    
    return html

def main():
    if len(sys.argv) < 2:
        print("Usage: generate-quotation.py <data.json> [output.pdf]")
        sys.exit(1)
    
    data_file = sys.argv[1]
    output_pdf = sys.argv[2] if len(sys.argv) > 2 else "quotation.pdf"
    
    with open(data_file, "r") as f:
        data = json.load(f)
    
    html = render_template(data)
    html_file = "/tmp/quot_gen.html"
    with open(html_file, "w") as f:
        f.write(html)
    
    # Convert to PDF
    cmd = ["wkhtmltopdf", "--page-size", "A4", "--margin-top", "20mm", "--margin-bottom", "20mm", "--margin-left", "15mm", "--margin-right", "15mm", html_file, output_pdf]
    subprocess.run(cmd, check=True)
    
    print(f"✅ PDF generated: {output_pdf}")

if __name__ == "__main__":
    main()