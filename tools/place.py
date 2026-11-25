#!/usr/bin/env python3
"""Lossless XML -> editable instance folders -> XML. Python 3, no dependencies."""
import argparse, collections, hashlib, json, pathlib, re, xml.etree.ElementTree as ET
ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = {'Script': 'init.server.luau', 'LocalScript': 'init.client.luau', 'ModuleScript': 'init.luau'}
def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
def encode(e):
    return {'tag':e.tag, 'attributes':dict(e.attrib), 'text':e.text, 'children':[encode(c) for c in e]}
def decode(d):
    e=ET.Element(d['tag'],d['attributes']); e.text=d['text']
    e.extend(decode(c) for c in d['children']); return e
def canonical(e):
    # Ignore only XML indentation between elements, never leaf content (including script whitespace).
    return (e.tag, sorted(e.attrib.items()), e.text if not len(e) or (e.text or '').strip() else None, [canonical(c) for c in e])
def export(source):
    tree=ET.parse(source).getroot(); entries=[]; scripts=[]; counts=collections.Counter(); refs={}
    def siblings(items, parent):
        used=set(); paths=[]
        for item in items:
            name=item.findtext('Properties/string[@name="Name"]') or item.get('class')
            safe=re.sub(r'[^\w. -]', '_', name).strip(' .') or 'Instance'
            candidate=safe; n=2
            while candidate.casefold() in used:
                candidate=f'{safe}__{n}'; n+=1
            used.add(candidate.casefold()); folder=parent/candidate; paths.append(str(folder.relative_to(ROOT/'src')))
            counts[item.get('class')]+=1
            ref=item.get('referent')
            if ref: refs[ref]=str(folder.relative_to(ROOT))
            props=item.find('Properties'); fields=[]
            for child in item:
                if child.tag=='Item': continue
                data=encode(child)
                if child.tag=='Properties':
                    for index, prop in enumerate(child):
                        if item.get('class') in SCRIPT and prop.get('name')=='Source':
                            filename=SCRIPT[item.get('class')]; source_text=prop.text or ''
                            (folder).mkdir(parents=True,exist_ok=True)
                            (folder/filename).write_text(source_text,encoding='utf-8',newline='')
                            data['children'][index]['text']=None
                            data['children'][index]['sourceFile']=filename
                            scripts.append({'path':str((folder/filename).relative_to(ROOT)), 'className':item.get('class'), 'sha256':hashlib.sha256(source_text.encode()).hexdigest()})
                fields.append(data)
            children=siblings(item.findall('Item'),folder)
            write(folder/'instance.json',{'attributes':dict(item.attrib),'fields':fields,'children':children,'layout':[c.tag=='Item' for c in item]})
        return paths
    children=siblings(tree.findall('Item'),ROOT/'src')
    write(ROOT/'src/place.json',{'attributes':dict(tree.attrib),'fields':[encode(c) for c in tree if c.tag!='Item'],'children':children,'layout':[c.tag=='Item' for c in tree]})
    write(ROOT/'docs/inventory.json',{'instances':sum(counts.values()),'classes':dict(sorted(counts.items())),'scripts':scripts,'referents':refs})
    print(f'Exported {sum(counts.values())} instances, {len(scripts)} scripts')
def build(output):
    def node(path):
        folder=ROOT/'src'/path; d=json.loads((folder/'instance.json').read_text()); e=ET.Element('Item',d['attributes'])
        for field in d['fields']:
            for prop in field.get('children',[]):
                if 'sourceFile' in prop: prop['text']=(folder/prop.pop('sourceFile')).read_text(encoding='utf-8')
            e.append(decode(field))
        items=iter(node(c) for c in d['children']); fields=iter(list(e)); e[:]=[next(items) if is_item else next(fields) for is_item in d['layout']]; return e
    d=json.loads((ROOT/'src/place.json').read_text()); root=ET.Element('roblox',d['attributes'])
    fields=iter(decode(f) for f in d['fields']); items=iter(node(c) for c in d['children']); root.extend(next(items) if is_item else next(fields) for is_item in d['layout'])
    pathlib.Path(output).parent.mkdir(parents=True,exist_ok=True)
    ET.ElementTree(root).write(output,encoding='utf-8',xml_declaration=True)
    return root
if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('command',choices=['export','build','verify']); p.add_argument('path',nargs='?'); a=p.parse_args()
    original=ROOT/'Roblox Hexball.rbxlx'
    if a.command=='export': export(a.path or original)
    elif a.command=='build': build(a.path or ROOT/'build/Roblox-Hexball.rbxlx')
    else:
        rebuilt=build(ROOT/'build/Roblox-Hexball.rbxlx')
        assert canonical(ET.parse(original).getroot())==canonical(rebuilt), 'Round-trip differs'
        print('PASS: every instance, property, reference and script matches the original XML')
