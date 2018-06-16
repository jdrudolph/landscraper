from reportlab.lib.enums import TA_JUSTIFY
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image
from reportlab.platypus.tables import Table
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

doc = SimpleDocTemplate("form_letter.pdf")
styles = getSampleStyleSheet()

header = Paragraph("Lawn make-over report", styles['h1'])
greeting = Paragraph('hi jannis', styles['Normal'])

materials_header = Paragraph("Materials", styles['h2'])
data = [('Dirt', '50 m³'), ('Cobble', '10 m³'), ('Wood', '4 m³'), ('', '64 m³')]
table_style = [
	('LINEABOVE', (0, 0), (-1, 0), 1, (0, 0, 0)),
	('ALIGN', (-1, 0), (-1, -1), 'RIGHT'),
	('LINEBELOW', (0, -2), (-1, -2), 3, (0, 0, 0)),
	('LINEBELOW', (0, -2), (-1, -2), 1, (1, 1, 1)),
]
table = Table(data, colWidths=[400, 50], style=table_style)

excess_header = Paragraph("Excess materials", styles['h2'])
excess_data = [('Leaves', '10 m³'), ('', '10 m³')]
excess_table = Table(excess_data, colWidths=[400, 50], style=table_style)

tools_header = Paragraph("Tools", styles['h2'])
tools_data = [('', 10), ('', 10)]
tools_table = Table(tools_data, colWidths=[400, 50], style=[('LINEABOVE', (0, 0), (-1, 0), 1, (0, 0, 0))])

floor_plan = Image("outline.png", 300, 300)


items = [header,greeting, materials_header, table, excess_header, excess_table, floor_plan]
doc.build(items)
