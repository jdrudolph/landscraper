from reportlab.lib.enums import TA_JUSTIFY, TA_CENTER
from reportlab.platypus import BaseDocTemplate, PageTemplate, Paragraph, Spacer, Image, Frame, FrameBreak
from reportlab.platypus.tables import Table
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
import pandas as pd
from os import path
df = pd.read_csv(path.join('..', '..', 'worlds', 'Techfest', 'blocks.txt'),
names = ['action', 'material', 'tool'])

changed_materials = df.groupby('action')['material'].value_counts()
changed_materials.name = 'count'
changed_materials = changed_materials.reset_index()

changed_materials['count'] = changed_materials['count'] * ([-1 if x else 1 for x in changed_materials['action'] == '-'])
changed_materials['material'] = changed_materials['material'].str.split(':').str.get(1).str.replace('_', ' ')

materials = changed_materials.groupby('material')['count'].sum().reset_index()

materials_data = [(material, '{} m³'.format(count)) for material, count in materials[['material', 'count']].values if count > 0]
materials_data.append(('', '{} m³'.format(sum([int(count.split(' ')[0]) for _, count in materials_data]))))
excess_data = [(material, '{} m³'.format(-count)) for material, count in materials[['material', 'count']].values if count < 0]
excess_data.append(('', '{} m³'.format(sum([int(count.split(' ')[0]) for _, count in excess_data]))))

tools = df[df['action'] == '-']['tool'].value_counts().reset_index()
tools['index'] = tools['index'].str.split(':').str.get(1).str.replace('_', ' ')
tools_data = [(tool, count) for tool, count in tools.values]
tools_data = [(tool, "{} usages".format(count)) for tool, count in tools_data]

"""
Report pdf generation
"""
frame_header = Frame(350, 700, 210, 120, showBoundary=False)
frame_rest = Frame(72, 72, 450, 700, showBoundary=False)

styles = getSampleStyleSheet()
main_page = PageTemplate(frames=[frame_header, frame_rest])
doc = BaseDocTemplate("lisht_report.pdf", pageTemplates=main_page)

story = []
lisht = Image("lisht_logo.png", 180, 80, hAlign='CENTER')
greeting_style = ParagraphStyle(name='Right', parent=styles['Normal'], alignment=TA_CENTER)
greeting = Paragraph('Landscaping ISH Toll', greeting_style)
story = story + [lisht, greeting, FrameBreak() ]

header = Paragraph("Lawn make-over report", styles['h1'])
story = story + [header]

materials_header = Paragraph("Materials", styles['h2'])
table_style = [
	('ALIGN', (-1, 0), (-1, -1), 'RIGHT'),
	('LINEBELOW', (0, -2), (-1, -2), 1, (0, 0, 0)),
]
materials_table = Table(materials_data, colWidths=[400, 50], style=table_style)
story = story + [materials_header, materials_table]

excess_header = Paragraph("Excess materials", styles['h2'])
excess_table = Table(excess_data, colWidths=[400, 50], style=table_style)
story = story + [excess_header, excess_table]

tools_header = Paragraph("Tools", styles['h2'])
tools_table = Table(tools_data, colWidths=[400, 50])
story = story + [tools_header, tools_table]

floor_header = Paragraph("Topographical map", styles['h2'])
floor_plan = Image("outline.png", 300, 200)
story = story + [floor_header, floor_plan]

doc.build(story)
