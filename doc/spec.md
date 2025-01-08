# RDF/Borsh Binary Serialization Format Specification

Version: 1.0

## Overview

RDF/Borsh is a binary serialization format for RDF (Resource Description Framework) data, designed for efficient storage and transmission of RDF graphs and datasets. It uses LZ4 compression for the terms dictionary and quads sections.

## File Structure

An RDF/Borsh file consists of three main sections:
1. Header (uncompressed)
2. Terms Dictionary (LZ4-compressed)
3. Quads Section (LZ4-compressed)

### Header Format

The header is a fixed-size, uncompressed section at the beginning of the file:

```
Offset  Size    Description
0       4       Magic number ("RDFB")
4       1       Version number (0x01)
5       1       Flags (0b00000111)
6       4       Total number of quads (uint32, little-endian)
```

### Terms Dictionary Section

The terms dictionary section begins immediately after the header:

```
Offset  Size    Description
0       4       Compressed block size N (uint32, little-endian)
4       N       LZ4-compressed terms block
```

The uncompressed terms block has the following structure:
```
Offset  Size    Description
0       4       Number of terms M (uint32, little-endian)
4       var     M term entries
```

Each term entry has one of the following formats based on its type identifier:

1. IRI (Type = 1):
```
0       1       Type identifier (0x01)
1       4       String length N (uint32, little-endian)
5       N       IRI string (UTF-8)
```

2. Blank Node (Type = 2):
```
0       1       Type identifier (0x02)
1       4       String length N (uint32, little-endian)
5       N       Node ID string (UTF-8)
```

3. Plain Literal (Type = 3):
```
0       1       Type identifier (0x03)
1       4       String length N (uint32, little-endian)
5       N       Literal value (UTF-8)
```

4. Typed Literal (Type = 4):
```
0       1       Type identifier (0x04)
1       4       Value length N (uint32, little-endian)
5       N       Literal value (UTF-8)
N+5     4       Datatype IRI length M (uint32, little-endian)
N+9     M       Datatype IRI string (UTF-8)
```

5. Language-tagged Literal (Type = 5):
```
0       1       Type identifier (0x05)
1       4       Value length N (uint32, little-endian)
5       N       Literal value (UTF-8)
N+5     4       Language tag length M (uint32, little-endian)
N+9     M       Language tag string (ASCII)
```

### Quads Section

The quads section follows the terms dictionary:

```
Offset  Size    Description
0       4       Compressed block size N (uint32, little-endian)
4       N       LZ4-compressed quads block
```

The uncompressed quads block has the following structure:
```
Offset  Size    Description
0       4       Number of quads M (uint32, little-endian)
4       var     M quad entries
```

Each quad entry is 8 bytes:
```
0       2       Graph term ID (uint16, little-endian)
2       2       Subject term ID (uint16, little-endian)
4       2       Predicate term ID (uint16, little-endian)
6       2       Object term ID (uint16, little-endian)
```

## Term References

- Term IDs are 1-based indices into the terms dictionary
- Term ID 0 is reserved to represent the default graph
- Terms are deduplicated in the dictionary
- Term IDs must be less than 65,536 (maximum value of uint16)

## Compression

- The terms dictionary and quads sections are compressed using LZ4 with the following parameters:
  - Block compression mode
  - High compression mode (HC)
  - Maximum compression level (12)
- Each compressed section is preceded by its compressed size as a uint32

## Flags

The flags byte in the header currently uses bits 0-2 (0b00000111). All other bits are reserved for future use and must be set to 0.

## Version History

- Version 1: Initial release

## MIME Type and File Extension

- MIME Type: application/x-rdf+borsh
- File Extension: .rdfb

## Implementation Notes

- Implementations must validate the magic number and version before processing
- Implementations should ignore unknown flag bits
- All multi-byte integers are encoded in little-endian order
- Strings must be encoded in UTF-8, except language tags which use ASCII
- Term dictionary size is limited to 65,535 entries (0xFFFF) due to uint16 term references
- The format supports up to 4,294,967,295 quads (uint32 max)
