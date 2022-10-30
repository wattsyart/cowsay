// SPDX-License-Identifier: Artistic-1.0
pragma solidity ^0.8.17;

/*
 _________________________________________
< I don't know why I did this, send help. >
 -----------------------------------------
    \  ^__^
     \ (**)\_______
       (__)\       )\/\
        U  ||----w |
           ||     ||
*/

import "./lib/strings.sol";

library CowLib {

    using CowLib for *;
    using strings for *;    
    
    enum FaceType {
        Default,
        Borg,
        Dead,
        Greedy,
        Paranoid,
        Stoned,
        Tired,
        Wired,
        Young,        
        Custom
    }

    struct Face {
        string eyes;
        string ears;        
        string tongue;
    }

    enum BubbleType {
        Say,
        Think,
        Custom
    }
    
    struct Bubble {
        string topLine;
        string topLeft;
        string topRight;
        string left;
        string leftSingle;
        string right;
        string rightSingle;
        string bottomLeft;
        string bottomRight;
        string bottomLine;
        string thoughts;
    }

    enum CowType {
        Default,
        Custom
    }

    /// @notice Options for cow processing
    /// @param wordWrap If true, words are wrapped along @maxLineLength; if false, @newLine in the input are relied on
    /// @param maxLineLength Sets the breakpoint for lines when @wordWrap is true
    /// @param cowType Used to flag whether to use the default cow or to parse a custom cow from @cowFile     
    /// @param cowFile Must contain the custom cowfile template when @cowType is Custom
    /// @param faceType Used to flag whether to use a templated default face, or a custom face from @face
    /// @param face Must contain the face configuration when @faceType is Custom
    /// @param bubbleType Used to flag whether to use a templated default speech bubble, or a custom bubble from @bubble
    /// @param bubble Must contain the bubble configuration when @bubbleType is Custom
    /// @param newLine The type of new lines to emit and parse. Default should be `\n`. Better to normalize on this than to change it.
    /// @param emptyText The value to use for the speech output when no input is provided
    struct Options {
        bool wordWrap;
        uint maxLineLength;
        CowType cowType;
        string cowFile;
        FaceType faceType;
        Face face;
        BubbleType bubbleType; 
        Bubble bubble;        
        string newLine;
        string emptyText;
    }

    struct DrawBubble {
        uint longestLine;
        string firstLine;        
        uint firstLineLength;
        string newLine;
    }

    struct CowMap {
        string[] names;
        string[] values;
        mapping(string => uint) indices;
    }

    function length(CowMap storage map) internal view returns (uint256) {
        return map.values.length;
    }

    function add(CowMap storage map, string memory name, string memory value) internal returns (bool) {
        if (map.indices[name] == 0) {
            map.names.push(name);
            map.values.push(value);
            map.indices[name] = map.values.length;
            return true;
        } else {
            return false;
        }
    }

    function get(CowMap storage map, string memory name) internal view returns (string memory) {
        uint index = map.indices[name] - 1;
        return map.values[index];
    }

    function getNames(CowMap storage map) internal view returns (string[] memory) {
        return map.names;
    }

    function remove(CowMap storage map, string memory name) internal returns (bool) {
        uint256 index = map.indices[name];
        if (index != 0) {
            uint256 deleteAt = index - 1;
            uint256 last = map.values.length - 1;
            if (last != deleteAt) {
                string memory lastName = map.names[last];                
                string memory lastValue = map.values[last];
                
                map.names[deleteAt] = lastName;
                map.values[deleteAt] = lastValue;
                map.indices[lastValue] = index;
            }
            map.values.pop();
            map.names.pop();
            delete map.indices[name];            
            return true;
        } else {
            return false;
        }
    }

    function drawBubble(string memory input, Options memory options) internal pure returns (string memory) {
        options.bubble = options.bubbleType == BubbleType.Custom ? options.bubble : createBubblePrefab(options.bubbleType);        

        DrawBubble memory f;

        string[] memory lines = CowLib.layoutText(input, options);
        if(lines.length == 0) {
            lines = new string[](1);
            lines[0] = options.emptyText;
        }
        
        f.longestLine = 0;
        for(uint i = 0; i < lines.length; i++) {
            uint lineLength = lines[i].strlen();
            if(lineLength> f.longestLine)                
                f.longestLine = lineLength;
        }        

        f.firstLine = lines[0];
        f.firstLineLength = f.firstLine.strlen();
        f.newLine = options.newLine;

        if(lines.length == 1) {         
            bytes memory topBubble = abi.encodePacked(' ', repeat(options.bubble.topLine, f.firstLineLength + 2));            
            bytes memory bottomBubble = abi.encodePacked(' ', repeat(options.bubble.bottomLine, f.firstLineLength + 2));
            return string(abi.encodePacked(
                    topBubble, options.newLine, 
                    options.bubble.leftSingle, ' ', f.firstLine, ' ', options.bubble.rightSingle, f.newLine,
                    bottomBubble
                )
            );
        } else {               
            bytes memory topBubble = abi.encodePacked(' ', repeat(options.bubble.topLine, f.longestLine + 2));
            bytes memory firstLinePadding = abi.encodePacked(repeat(' ', f.longestLine - f.firstLineLength + 1));
            bytes memory firstBubbleLine = abi.encodePacked(options.bubble.topLeft, ' ', f.firstLine, firstLinePadding, options.bubble.topRight);
            bytes memory middleBubbleLines = abi.encodePacked('');
            for(uint i = 1; i < lines.length - 1; i++) {
                bytes memory padding = abi.encodePacked(repeat(' ', f.longestLine - lines[i].strlen() + 1));
                middleBubbleLines = abi.encodePacked(middleBubbleLines, options.bubble.left, ' ', lines[i], padding, options.bubble.right, f.newLine);
            }              
            bytes memory lastLinePadding = abi.encodePacked(repeat(' ', f.longestLine - lines[lines.length - 1].strlen() + 1));
            bytes memory lastBubbleLine = abi.encodePacked(options.bubble.bottomLeft, ' ', lines[lines.length - 1], lastLinePadding, options.bubble.bottomRight);
            bytes memory bottomBubble = abi.encodePacked(' ', repeat(options.bubble.bottomLine, f.longestLine + 2));        
            
            return string(abi.encodePacked(
                topBubble, f.newLine, 
                firstBubbleLine, f.newLine,
                middleBubbleLines,
                lastBubbleLine, f.newLine,
                bottomBubble)
            );
        }
    }    

    function drawCow(Options memory options) internal pure returns (string memory) {
        bytes memory sb;
        options.face = options.faceType == FaceType.Custom ? options.face : createFacePrefab(options.faceType);
        if(options.cowType == CowType.Default) {            
            sb = abi.encodePacked(sb, '    ', options.bubble.thoughts, '  ', options.face.ears, '__', options.face.ears, options.newLine);
            sb = abi.encodePacked(sb, '     ', options.bubble.thoughts, ' (', options.face.eyes, ')\\_______', options.newLine);
            sb = abi.encodePacked(sb, '       (__)\\       )\\/\\', options.newLine);
            sb = abi.encodePacked(sb, '        ', options.face.tongue, ' ||----w |', options.newLine);
            sb = abi.encodePacked(sb, '           ||     ||', options.newLine);            
        } else {
            return drawCowFile(options);
        }
        return string(sb);
    }

    struct CowFileParser {
        strings.slice newLine;
        strings.slice start;        
        strings.slice thoughts;
        strings.slice thoughtsToken;
        strings.slice eyes;
        strings.slice eyesToken;
        strings.slice threeEyes;
        strings.slice tongue;
        strings.slice tongueToken;        
        strings.slice end;        
    }

    function getCowFileParser(Options memory options) internal pure returns (CowFileParser memory parser) {
        parser.newLine = options.newLine.toSlice();
        parser.start = "$the_cow =".toSlice();
        parser.thoughts = "$thoughts".toSlice();
        parser.thoughtsToken = options.bubble.thoughts.toSlice();        
        parser.eyes = "$eyes".toSlice();
        parser.eyesToken = options.face.eyes.toSlice();
        parser.threeEyes = "$extra = chop($eyes)".toSlice();
        parser.tongue = "$tongue".toSlice();
        parser.tongueToken = options.face.tongue.toSlice();
        parser.end = "EOC".toSlice();
    }

    function drawCowFile(Options memory options) internal pure returns (string memory) {
        CowFileParser memory p = getCowFileParser(options);
        string[] memory lines = splitIntoLines(options.cowFile, p.newLine);
        bool started;
        strings.slice memory cow;        
        for(uint i = 0; i < lines.length; i++) {            
            
            strings.slice memory line = lines[i].toSlice();

            if(line.startsWith(p.start)) {
                started = true;
                continue;
            }

            if(line.startsWith(p.threeEyes)) {
                if(p.eyesToken.len() < 3) {
                    strings.slice memory rune;
                    p.eyesToken = p.eyesToken.concat(p.eyesToken.copy().nextRune(rune)).toSlice();
                }
                continue;
            }

            
            if(started) {          
                if(line.equals(p.end)) return cow.toString();

                bool hasReplacements = true;

                while(hasReplacements)
                {
                    hasReplacements = false;
                    bool success;
                    strings.slice memory replaced;                
                
                    (success, replaced) = tryReplacePart(line.copy(), p.thoughts, p.thoughtsToken);
                    if(success) {
                        line = replaced;
                        hasReplacements = true;
                    }

                    (success, replaced) = tryReplacePart(line.copy(), p.eyes, p.eyesToken);
                    if(success) {
                        line = replaced;
                        hasReplacements = true;
                    }

                    (success, replaced) = tryReplacePart(line.copy(), p.tongue, p.tongueToken);
                    if(success) {
                        line = replaced;
                        hasReplacements = true;
                    }
                }

                strings.slice[] memory parts;
                parts = new strings.slice[](3);
                parts[0] = cow;
                parts[1] = line;
                parts[2] = p.newLine;
                cow = "".toSlice().join(parts).toSlice();
            }
        }

        return cow.toString();
    }

    function tryReplacePart(strings.slice memory line, strings.slice memory parameter, strings.slice memory token) internal pure returns (bool success, strings.slice memory replaced) {
        if(line.contains(parameter)) {   
            strings.slice[] memory parts;
            parts = new strings.slice[](3);
            parts[0] = line.split(parameter);
            parts[1] = token;
            parts[2] = line.beyond(parts[1].concat(parameter).toSlice());            
            replaced = "".toSlice().join(parts).toSlice();
            return (true, replaced);
        }
        return (false, line);
    }

    function createFacePrefab(FaceType faceType) internal pure returns (Face memory face) {        
        require(faceType != FaceType.Custom);
        face.eyes = "oo";
        face.ears = "^";
        face.tongue = "  ";

        if(faceType == FaceType.Default) {
            face.eyes = "oo";
        } else if(faceType ==  FaceType.Borg) {
            face.eyes = "==";
        } else if(faceType ==  FaceType.Dead) {
            face.eyes = "xx";            
            face.tongue = "U ";
        } else if (faceType ==  FaceType.Greedy) {
            face.eyes = "$$";            
        } else if (faceType ==  FaceType.Paranoid) {
            face.eyes = "@@";
        } else if (faceType ==  FaceType.Stoned) {            
            face.eyes = "**";
            face.tongue = "U ";
        } else if (faceType ==  FaceType.Tired) {
            face.eyes = "--";
        } else if (faceType ==  FaceType.Wired) {
            face.eyes = "OO";
        } else /* if (faceType == FaceType.Young) */ {
            face.eyes = "..";          
        }

        return face;
    }

    function createBubblePrefab(BubbleType bubbleType) internal pure returns (Bubble memory bubble) {        
        require(bubbleType != BubbleType.Custom);
        bubble.topLine = "_";
        if(bubbleType == BubbleType.Think) {
            bubble.topLeft = bubble.bottomLeft = bubble.left = bubble.leftSingle = "(";
            bubble.topRight = bubble.bottomRight = bubble.right = bubble.rightSingle = ")";
            bubble.thoughts = "o";
        } else {
            bubble.topLeft = bubble.bottomRight = "/";
            bubble.topRight = bubble.bottomLeft = bubble.thoughts = "\\";
            bubble.left = bubble.right = "|";
            bubble.leftSingle = "<";
            bubble.rightSingle = ">";
        }
        bubble.bottomLine = "-";
    }

    function repeat(string memory input, uint count) internal pure returns (string memory) {
        strings.slice memory token = input.toSlice();
        strings.slice memory toRepeat;
        for(uint i = 0; i < count; i++) {
            toRepeat = toRepeat.concat(token).toSlice();
        }
        return toRepeat.toString();
    }

    function splitIntoLines(string memory input, strings.slice memory newLine) internal pure returns (string[] memory lines) {
        strings.slice memory source = input.toSlice();
        lines = new string[](source.count(newLine) + 1);
        while(source.len() > 0) {
            for(uint i = 0; i < lines.length; i++) {
                lines[i] = source.split(newLine).toString();
            }
        }
    }

    function layoutText(string memory input, Options memory options)
        internal
        pure
        returns (string[] memory lines)
    {
        strings.slice memory source = input.toSlice();
        strings.slice memory delimiter = ' '.toSlice();
        strings.slice memory newLine = options.newLine.toSlice();
        strings.slice memory empty = "".toSlice();        

        uint256 lineCount;
        strings.slice memory working = source.copy();                
        strings.slice memory line = empty;

        while (working.len() > 0) {
            strings.slice memory word = working.split(delimiter);            
            if(word.startsWith(newLine)) {
                lineCount++;
                line = word.split(newLine);
            } else if(word.contains(newLine)) {                
                strings.slice memory left = word.copy().split(newLine);                    
                strings.slice memory right = word.copy().beyond(left.concat(newLine).toSlice());
                line = line.concat(delimiter).toSlice().concat(left).toSlice();
                lineCount++;           
                line = right;
                continue;
            }
            if (options.wordWrap) {
                if(line.len() + delimiter.len() + word.len() <= options.maxLineLength) {
                    if (line.len() == 0) {
                        line = line.concat(word).toSlice();
                    } else {
                        line = line.concat(delimiter).toSlice().concat(word).toSlice();
                    }
                } else {
                    if(line.len() > 0) {
                        lineCount++;
                    }
                    line = word;
                }
            } else {
                line = line.concat(delimiter).toSlice().concat(word).toSlice();
            }
        }
        if (line.len() > 0) {
            lineCount++;
        }
        
        lines = new string[](lineCount);

        lineCount = 0;
        working = source.copy();                
        line = empty;

        while (working.len() > 0) {
            strings.slice memory word = working.split(delimiter);

            if(word.startsWith(newLine)) {
                lines[lineCount++] = line.toString();
                line = word.split(newLine);
            } else if(word.contains(newLine)) {
                strings.slice memory left = word.copy().split(newLine);                    
                strings.slice memory right = word.copy().beyond(left.concat(newLine).toSlice());
                line = line.concat(delimiter).toSlice().concat(left).toSlice();
                lines[lineCount++] = line.toString();                
                line = right;
                continue;
            }
            if (options.wordWrap) {
                if(line.len() + delimiter.len() + word.len() <= options.maxLineLength) {
                    if (line.len() == 0) {
                        line = line.concat(word).toSlice();
                    } else {
                        line = line.concat(delimiter).toSlice().concat(word).toSlice();
                    }
                } else {
                    if(line.len() > 0) {
                        lines[lineCount++] = line.toString();
                    }                
                    line = word;
                }                
            } else {
                line = line.concat(delimiter).toSlice().concat(word).toSlice();
            }
        }
        if (line.len() > 0) {
            lines[lineCount++] = line.toString();
        }
    }

    // SPDX-License-Identifier: MIT
    // Source: https://github.com/ensdomains/ens-contracts/blob/master/contracts/ethregistrar/StringUtils.sol
    function strlen(string memory s) internal pure returns (uint256) {        
        uint256 len;
        uint256 i = 0;
        uint256 bytelength = bytes(s).length;
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }
}
