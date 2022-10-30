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

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CowLib.sol";


/// @title Cowsay.sol
/// @author Originally developed by Tony Monroe, ported to Solidity by @wattsyart (wattsyart@protonmail.com)
/// @notice Outputs input text, as orated by an ASCII art cow, in 2022
contract Cowsay is Ownable {

    mapping(string => string) public cows;

    /// @notice Adds a new custom cowfile to the contract
    /// @dev Example cowfiles are viewable at https://github.com/schacon/cowsay
    /// @param name The lookup key for the new cowfile
    /// @param template The cowfile template text    
    function setCow(string memory name, string memory template) external onlyOwner {
        cows[name] = template;
    }

    /// @notice Cow says something, with all default values
    /// @param input The text to say
    function cowsay(string memory input) external pure returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.bubbleType = CowLib.BubbleType.Say;        
        return _cow(input, options);
    }

    /// @notice Cow says something, with user-provided options
    /// @param input The text to say
    /// @param options Options to customize the output (you must set all required options yourself)    
    function cowsay(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    /// @notice Cow says something, with all default values, using a custom cow
    /// @param input The text to say
    /// @param input The lookup key for the custom cowfile
    function cowsay(string memory input, string memory cowName) external view returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    /// @notice Cow says something, with user-provided options, using a custom cow
    /// @param input The text to say
    /// @param cowName The lookup key for the custom cowfile
    /// @param options Options to customize the output (you must set all required options yourself)    
    function cowsay(string memory input, string memory cowName, CowLib.Options memory options) external view returns (string memory) {
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Say;
        return _cow(input, options);
    }

    /// @notice Cow thinks something, with all default values
    /// @param input The text to think
    function cowthink(string memory input) external pure returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    /// @notice Cow thinks something, with user-provided options
    /// @param input The text to think
    /// @param options Options to customize the output (you must set all required options yourself)
    function cowthink(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    /// @notice Cow thinks something, with all default values, using a custom cow    
    /// @param input The text to think
    /// @param cowName The lookup key for the custom cowfile
    function cowthink(string memory input, string memory cowName) external view returns (string memory) {
        CowLib.Options memory options = getDefaultOptions();
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    /// @notice Cow thinks something, with user-provided options, using a custom cow
    /// @param input The text to think
    /// @param cowName The lookup key for the custom cowfile
    /// @param options Options to customize the output (you must set all required options yourself)
    function cowthink(string memory input, string memory cowName, CowLib.Options memory options) external view returns (string memory) {
        options.cowType = CowLib.CowType.Custom;
        options.cowFile = cows[cowName];
        options.bubbleType = CowLib.BubbleType.Think;
        return _cow(input, options);
    }

    /// @notice Cow does something, with user-provided options
    /// @dev Use this when you want to customize everything, including the speech bubble
    /// @param input The text to cow-ify
    /// @param options Options to customize the output (you must set all required options yourself)
    function cow(string memory input, CowLib.Options memory options) external pure returns (string memory) {
        return _cow(input, options);
    }

    /// @notice Cow does something, with user-provided options, using a custom cow
    /// @dev Use this when you want to customize everything, including the speech bubble
    /// @param input The text to cow-ify
    /// @param cowName The lookup key for the custom cowfile
    /// @param options Options to customize the output (you must set all required options yourself)
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