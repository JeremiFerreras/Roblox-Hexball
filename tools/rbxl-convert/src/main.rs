use std::{
    env,
    error::Error,
    fs::File,
    io::{BufReader, BufWriter},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = env::args().skip(1);
    let input = args.next().unwrap_or_else(|| "hexballactual.rbxl".to_owned());
    let output = args
        .next()
        .unwrap_or_else(|| "Roblox Hexball.rbxlx".to_owned());

    let input_file = BufReader::new(File::open(&input)?);
    let dom = rbx_binary::from_reader(input_file)?;

    // rbx_binary wraps loaded places in a DataModel. Serialize the place's
    // direct children to XML, matching the root layout expected by place.py.
    let roots = dom.root().children().to_vec();
    println!("Decoded {} root instances from {}", roots.len(), input);

    let output_file = BufWriter::new(File::create(&output)?);
    rbx_xml::to_writer_default(output_file, &dom, &roots)?;

    println!("Wrote {}", output);
    Ok(())
}
