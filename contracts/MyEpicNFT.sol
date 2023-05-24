// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 constant MINT_LIMIT = 50;
  
  string svgPartOne = "<svg  xmlns='http://www.w3.org/2000/svg'  preserveAspectRatio='xMinYMin meet'  viewBox='0 0 350 350'>  <defs>    <linearGradient id='Gradient1'>      <stop class='stop1' offset='0%'/>      <stop class='stop2' offset='50%'/>      <stop class='stop3' offset='100%'/>    </linearGradient>  </defs>  <style>    .base {      fill: blue;      font-family: serif;      font-size: 20px;      color: #FFF;    }    .stop1 { stop-color: ";
  
  string svgPartTwo = "; }    .stop2 { stop-color: white; stop-opacity: 0; }    .stop3 { stop-color: yellow; }      </style>  <rect width='100%' height='100%' fill='url(#Gradient1)' />  <text    x='50%'    y='50%'    class='base'    dominant-baseline='middle'    text-anchor='middle'  >";

  string[] firstWords = ["Tubaina 1", "Guarana", "Fanta", "Doly", "Grapete"];
  string[] secondWords = ["Moqueca", "Feijoada", "Vatapa", "Acaraje", "Rabada", "Dobradinha"];
  string[] thirdWords = ["Maracuja", "Pitanga", "Graviola", "Acai", "Banana", "Amora"];

  // Cores divertidas! Declarando um monte de cores
  string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("ChavesNFT", "CHAVO") {
    console.log("Meu contrato de NFT! Tchu-hu");
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("PRIMEIRA_PALAVRA", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SEGUNDA_PALAVRA", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("TERCEIRA_PALAVRA", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  // Mesma coisa de sempre, pega uma cor aleatória.
  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function getCurrentTokenId() public view returns (uint256) {
    return _tokenIds.current();
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();
    require(newItemId < MINT_LIMIT, "Total mint amount reached");

    // Agora pegamos uma palavra aleatoria de cada uma das 3 listas.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    string memory randomColor = pickRandomColor(newItemId);

    // Concateno tudo junto e fecho as tags <text> e <svg>.
    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

    // pego todos os metadados de JSON e codifico com base64.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // Definimos aqui o titulo do nosso NFT sendo a combinacao de palavras.
                    combinedWord,
                    '", "description": "Uma colecao aclamada e famosa de NFTs maravilhosos.", "image": "data:image/svg+xml;base64,',
                    // Adicionamos data:image/svg+xml;base64 e acrescentamos nosso svg codificado com base64.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Assim como antes, prefixamos com data:application/json;base64
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // AQUI VAI A NOVA URI DINAMICAMENTE GERADA!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("Um NFT com ID %s foi cunhado para %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}