"""Check that the committed place contains the editable scripts and valid references."""
import collections
import json
import pathlib
import xml.etree.ElementTree as ET

ROOT=pathlib.Path(__file__).resolve().parents[1]
root=ET.parse(ROOT/'Roblox Hexball.rbxlx').getroot()
items=list(root.iter('Item'))
ids=[i.attrib['referent'] for i in items]
assert len(ids)==len(set(ids)), 'Duplicate referents'
known=set(ids)|{'null','nil',None}
assert all(ref.text in known for ref in root.iter('Ref')), 'Dangling instance reference'
by_id={i.attrib['referent']:i for i in items}
source_count=0
for path in (ROOT/'src').rglob('instance.json'):
    data=json.loads(path.read_text(encoding='utf-8'))
    assert len(data['layout'])==len(data['fields'])+len(data['children']), path
    item=by_id[data['attributes']['referent']]
    for field in data['fields']:
        for prop in field.get('children',[]):
            if 'sourceFile' in prop:
                original=(path.parent/prop['sourceFile']).read_text(encoding='utf-8')
                assert item.find('Properties/ProtectedString[@name="Source"]').text==original, path
                source_count+=1
assert source_count==len(list((ROOT/'src').rglob('*.luau'))), 'Unregistered scripts'
inventory=json.loads((ROOT/'docs/inventory.json').read_text(encoding='utf-8'))
assert inventory['instances']==len(items)
assert inventory['classes']==dict(collections.Counter(i.attrib['class'] for i in items))
print(f'PASS: {len(items)} instances, {source_count} sources, unique IDs and resolved references')
