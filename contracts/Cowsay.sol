// SPDX-License-Identifier: Artistic-1.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CowLib.sol";

contract Cowsay is Ownable {

    mapping(string => string) cows;

    function setCow(string memory name, string memory template) external onlyOwner {
        cows[name] = template;
    }

    function cowsay(string memory input) external pure returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.bubbleType = CowLib.BubbleType.Say;        
        return _cow(input, options);
    }

    function cowsay(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    function cowsay(string memory input, string memory cowName) external view returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    function cowsay(string memory input, string memory cowName, CowLib.Options memory options) external view returns (string memory) {
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    function cowthink(string memory input) external pure returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    function cowthink(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    function cowthink(string memory input, string memory cowName) external view returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    function cowthink(string memory input, string memory cowName, CowLib.Options memory options) external view returns (string memory) {
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    function cow(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        return _cow(input, options);
    }

    function cow(string memory input, string memory cowName, CowLib.Options memory options) external view returns (string memory) {
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        return _cow(input, options);
    }

    function _cow(string memory input, CowLib.Options memory options) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                CowLib.drawBubble(input, options), options.newLine,              
                CowLib.drawCow(options)
            )
        );
    }

    function getDefaultOptions() private pure returns (CowLib.Options memory options) {
        options.newLine = '\n';
        options.maxLineLength = 40;
        options.emptyText = '...';
        options.wordWrap = true;
        options.faceType = CowLib.FaceType.Default;
    }
}