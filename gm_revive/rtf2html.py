import re, html
def rtf_to_html(rtf):
    i = rtf.find('{\\rtf')
    if i < 0: return html.escape(rtf)
    rtf = rtf[i:]
    # drop font/color tables
    rtf = re.sub(r'\{\\(fonttbl|colortbl|\*)[^{}]*(\{[^{}]*\}[^{}]*)*\}', '', rtf)
    out = []; bold = False; size = 24; open_span = False
    tokens = re.findall(r"\\'[0-9a-fA-F]{2}|\\[a-zA-Z]+-?\d* ?|\\[{}\\]|[{}]|[^\\{}]+", rtf)
    def span():
        nonlocal open_span
        if open_span: out.append('</span>')
        out.append(f'<span style="font-size:{size/2}pt;font-weight:{"bold" if bold else "normal"}">'); open_span = True
    span()
    centered = False
    for t in tokens:
        if t.startswith("\\'"): out.append(html.escape(bytes([int(t[2:], 16)]).decode('cp1252'))); continue
        if t in ('{', '}'): continue
        if t in ('\\{', '\\}', '\\\\'): out.append(html.escape(t[1])); continue
        if t.startswith('\\'):
            m = re.match(r'\\([a-zA-Z]+)(-?\d*)', t); w, n = m.group(1), m.group(2)
            if w == 'par': out.append('<br>\n')
            elif w == 'b': bold = n != '0'; span()
            elif w == 'fs': size = int(n or 24); span()
            elif w == 'tab': out.append('&emsp;')
            continue
        out.append(html.escape(t.replace('\r', '').replace('\n', '')))
    if open_span: out.append('</span>')
    return ''.join(out)
