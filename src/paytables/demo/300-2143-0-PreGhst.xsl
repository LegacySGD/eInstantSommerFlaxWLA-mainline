<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>
			
			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,getType">
				<lxslt:script lang="javascript">
					<![CDATA[

					const crosswordWidth = 11;
					const crosswordHeight = 11;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						// General game parameters and information
						var scenario = getScenario(jsonContext);
						var gameData = scenario.split("|");
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');

						// GAME 1 - Key Number Match 5 of 20
						var KNMwinningNums = KNMgetWinningNumbers(gameData[0]);
						var KNMoutcomeNums = KNMgetOutcomeData(gameData[0], 0);
						var KNMoutcomePrizes = KNMgetOutcomeData(gameData[0], 1);

						// Output winning numbers table.
						var r = [];
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
 						r.push('<tr><td class="tablehead">');
 						r.push(getTranslationByName("KNMTitle", translations));
 						r.push('</td></tr>'); 
 						r.push('<tr><td class="tablehead" colspan="' + KNMwinningNums.length + '">');
 						r.push(getTranslationByName("winningNumbers", translations));
 						r.push('</td></tr>'); 
 						r.push('<tr>');
 						for(var i = 0; i < KNMwinningNums.length; ++i)
 						{
 							r.push('<td class="tablebody">');
 							r.push(KNMwinningNums[i]);
 							r.push('</td>');
 						}
 						r.push('</tr>'); 
 						r.push('</table>'); 

						// Output outcome numbers table.
 						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
 						r.push('<td class="tablehead" width="50%">');
 						r.push(getTranslationByName("yourNumbers", translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" width="50%">');
 						r.push(getTranslationByName("boardValues", translations));
						r.push('</td>');
 						r.push('</tr>');
						for(var i = 0; i < KNMoutcomeNums.length; ++i)
						{
							r.push('<tr>');
							r.push('<td class="tablebody" width="50%">');
 							if(KNMcheckMatch(KNMwinningNums, KNMoutcomeNums[i]))
 							{
 								r.push(getTranslationByName("youMatched", translations) + ': ');
 							}
 							r.push(KNMoutcomeNums[i]);
 							r.push('</td>');
 							r.push('<td class="tablebody" width="50%">');
 							r.push(convertedPrizeValues[KNMgetPrizeNameIndex(prizeNames, KNMoutcomePrizes[i])]);
							r.push('</td>');
 						r.push('</tr>');
						} 
						r.push('</table>'); 
						r.push('<br />');

						// GAME 2 - 11 x 11 Crossword
						var crosswordBoard = [];
						var crosswordLetters = [];
						
						var crosswordContent = gameData[1].split(":");
						crosswordBoard = crosswordContent[0];
						crosswordLetters= crosswordContent[1];

						var crosswordLetter = crosswordLetters.split("");

						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable"');
 						r.push('<tr><td class="tablehead">');
 						r.push(getTranslationByName("CWDTitle", translations));
 						r.push('</td></tr>'); 
 						r.push('<tr><td class="tablehead">');
						r.push(getTranslationByName("drawnLetters", translations));
 						r.push('</td></tr>'); 
						r.push('</table>'); 
						
						//Drawn Letters
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable"');
						r.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length/2 + '">');
						r.push('</td></tr>');

						r.push('<tr>');
						for(var idxOfLetter = 0; idxOfLetter < crosswordLetter.length; ++idxOfLetter)
						{
							r.push('<td class="tablebody">');
							r.push(crosswordLetter[idxOfLetter]);
							r.push('</td>');
							if(idxOfLetter == (crosswordLetter.length / 2) - 1)
							{
								r.push('</tr>');
								r.push('<tr>');
							}								
						}
						//r.push('</td>');
						r.push('</tr>');
								
						//Words to Match
						r.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						r.push(getTranslationByName("wordToMatch", translations));
						r.push('</td></tr>');

						var crosswordWords = getCrosswordWords(crosswordBoard);
						var matchCount = 0;

						for(var idxOfWord = 0; idxOfWord < crosswordWords.length; ++idxOfWord)
						{
							r.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
							var word = crosswordWords[idxOfWord];
							matchChecked = CWDcheckMatch(crosswordLetter, word);
							if(matchChecked)
							{
								++matchCount;
								r.push(getTranslationByName("matched", translations) + ': ');
							}

							r.push(word);
							r.push('</td></tr>');
						}

						//Prize Results
						r.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						r.push(getTranslationByName("results", translations));
						r.push('</tr></td>');

						//Words Found
						r.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
						r.push(getTranslationByName("wordsFound", translations) + ': ');
						r.push(matchCount);
						r.push('</td></tr>');
								
						// Test
						var CWDwinLetter = CWDconvertWinsToLetter(matchCount);
						var CWDwinPrize;
						if (CWDwinLetter == 'Z')	
							CWDwinPrize = '0';
						else
							CWDwinPrize = convertedPrizeValues[prizeNames.indexOf(CWDwinLetter)];
						//Win Amount
						r.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
						r.push(getTranslationByName("crossword", translations) + ' ' + getTranslationByName("win", translations) + ': ' + CWDwinPrize);
						r.push('</td></tr>');
						r.push('</table>');
						r.push('<br />');

						// GAME 3 - Match 3 of 9
						var MATsymbolPotData = [];
						var MATturnDataArray = gameData[2].split('');
						for(var i = 0; i < prizeNames.length; i++)
						{
							MATsymbolPotData.push(new Pot(prizeNames[i]));
						}						
						for(var i = 0; i < MATturnDataArray.length; i++)
						{
							MATsymbolPotData = addToPotData(MATsymbolPotData,MATturnDataArray[i]);						
						}
						
						// Output winning numbers table.
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');
 						r.push('<tr><td class="tablehead">');
 						r.push(getTranslationByName("MATTitle", translations));
 						r.push('</td></tr>'); 
						r.push('<tr class="tablehead">');
						r.push('<td>');
						r.push(getTranslationByName("cash", translations));
						r.push('</td>');
						r.push('<td>');
						r.push(getTranslationByName("count", translations));
						r.push('</td>');
						r.push('<td>');
						r.push('</td>');
						r.push('<td>');
						r.push('</td>');
						r.push('</tr>');

						r.push('<tr class="tablehead">');
						for(var i = 0; i < MATsymbolPotData.length; i++)
						{
							if ((MATsymbolPotData[i].letter !== 'C') && (MATsymbolPotData[i].letter !== 'D')) // Miss C & D as they aren't used
							{ 
								r.push('<tr>');
								var matchedString = "";
								if(MATsymbolPotData[i].count == 3)
								{
									matchedString = getTranslationByName("youMatched", translations) + ": ";
								}							
								r.push('<td class="tablebody">');
								r.push(matchedString + convertedPrizeValues[prizeNames.indexOf(MATsymbolPotData[i].letter)]);
								r.push('</td>');
								r.push('<td class="tablebody">');
								r.push(MATsymbolPotData[i].count);
								r.push('</td>');
								r.push('</tr>');
							}
						}
						r.push('</tr>');
						r.push('</table>');
						r.push('<br />');
						
						// GAME 4 - Symbol Match
						var SYMPotData = [];
						var SYMgameData = gameData[3].split('');

						for(var i = 0; i < prizeNames.length; i++) 
						{
							SYMPotData.push(new Pot(prizeNames[i]));
						}						
						for(var i = 0; i < SYMgameData.length; i++)
						{
							SYMPotData = addToPotData(SYMPotData,SYMgameData[i]);
						}
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;overflow-x:scroll">');
 						r.push('<tr><td class="tablehead">');
 						r.push(getTranslationByName("SYMTitle", translations));
 						r.push('</td></tr>'); 
						r.push('<tr class="tablehead">');
							r.push('<td>');
							r.push(getTranslationByName("letter", translations));
							r.push('</td>');
							r.push('<td>');
							r.push(getTranslationByName("count", translations));
							r.push('</td>');
							r.push('<td>');
							r.push(getTranslationByName("requires", translations));
							r.push('</td>');
							r.push('<td>');
							r.push(getTranslationByName("wins", translations));
							r.push('</td>');
						r.push('</tr>');
						r.push('<tr class="tablehead">');
						for (var i = 0, winTotals=[9,0,8,7,0,0,6,5,4,3]; i <= SYMPotData.length; i++)
						{
							if (winTotals[i] > 0)
							{
							r.push('<tr>');
								r.push('<td>');
								//r.push(String.fromCharCode('A'.charCodeAt(0) + i));
								r.push(SYMPotData[i].letter)
								r.push('</td>');
								r.push('<td>');
								r.push(SYMPotData[i].count);
								r.push('</td>');
								r.push('<td>');
								r.push(winTotals[i]);
								r.push('</td>');
								r.push('<td>');
								if (SYMPotData[i].count == winTotals[i])
								{
									r.push((getTranslationByName("wins", translations)) + " " + convertedPrizeValues[prizeNames.indexOf(SYMPotData[i].letter)]);
								} 
								r.push('</td>');
							r.push('</tr>'); 
							}
						} 
						r.push('</tr>');
						r.push('</table>');
						return r.join('');
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function KNMgetWinningNumbers(scenario)
					{
						var numsData = scenario.split(";")[0];
						return numsData.split(","); 
					}

					// Input: "23,9,31,3|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function KNMgetOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split(";")[1];
						var outcomePairs = outcomeData.split(",");
						var r = [];
						for(var i = 0; i < outcomePairs.length; ++i)
						{
							r.push(outcomePairs[i].split(":")[index]);
						}
						return r; 
					}

					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function KNMcheckMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						return false; 
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function KNMgetPrizeNameIndex(prizeNames, currPrize)
					{			
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					// Input: number of word matches
					// Output: win letter
					function CWDconvertWinsToLetter(matches)
					{
						var wordsWin=[10,9,8,7,0,0,6,5,4,3];
						for(var i = 0; i < wordsWin.length; ++i)
						{
							if (wordsWin[i] > 0)
							{
								if (wordsWin[i] == matches)
								{
									return String.fromCharCode('A'.charCodeAt(0) + i);
								}
							}
						}
						return 'Z';
					}

					function CWDfindWinAmount(jsonContext, prizeValues, prizeNames)
					{
						var prizeOfCrosswordBoard = {};
						var prizeValuesArray = prizeValues.slice(1, prizeValues.length).split('|');
						var prizeNamesArray = prizeNames.slice(1, prizeNames.length).split(',');

						var result = 0;
						
						for(var idxOfPrize = 0; idxOfPrize < prizeNamesArray.length; ++idxOfPrize)
						{
							var prizeNameArray = prizeNamesArray[idxOfPrize].split(' ');
						
							if(prizeNameArray[2] == 'Match')
							{	
								prizeOfCrosswordBoard[prizeNameArray[1] + '_' + prizeNameArray[3]] = prizeValuesArray[idxOfPrize];
							}
						}

						//var scenario = getScenario(jsonContext);
						//var gameData = scenario.split("|");
						var crosswordBoard = [];
						var crosswordLetters = [];			

						var crosswordContent = gameData[1].split(":");
						crosswordBoard = crosswordContent[0];
						crosswordLetters = crosswordContent[1];
						var crosswordLetter = crosswordLetters.split("");

						var crosswordWords = getCrosswordWords(crosswordBoard);
						var matchCount = 0;
						for(var idxOfWord = 0; idxOfWord < crosswordWords.length; ++idxOfWord)
						{
							var word = crosswordWords[idxOfWord];
							matchChecked = CWDcheckMatch(crosswordLetter, word);
							if(matchChecked)
							{
								++matchCount;
							}
						}
						
						if('_' + matchCount in prizeOfCrosswordBoard)
						{
							result = prizeOfCrosswordBoard['_' + matchCount];
						}
						
						return result+''; 
					} 
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					//function getPricePoint(jsonContext)
					//{
						// Parse json and retrieve price point amount
					//	var jsObj = JSON.parse(jsonContext);
					//	var pricePoint = jsObj.amount;

					//	return pricePoint;
					//}

					function getCrosswordWords(crosswordBoard)
					{
						var crosswordRows = [];
						var crosswordCols = [];
						var lineStringRow = "";
						var lineStringCol = "";
						for(var x = 0; x < crosswordWidth; ++x)
						{
							for(var y = 0; y < crosswordHeight; ++y)
							{
								lineStringRow += crosswordBoard[y + (x * crosswordHeight)];
								lineStringCol += crosswordBoard[x + (y * crosswordWidth)];
							}
							crosswordRows.push(lineStringRow);
							crosswordCols.push(lineStringCol);
							lineStringRow = "";
							lineStringCol = "";
						}

						var crosswordWords = [];						
						for(var i = 0; i < crosswordRows.length; ++i)
						{
							addWords(crosswordRows[i], crosswordWords);
						}
						for(var i = 0; i < crosswordCols.length; ++i)
						{
							addWords(crosswordCols[i], crosswordWords);
						}
						return crosswordWords; 
					}

					function addWords(checkForWords, wordsArray)
					{
						var word = "";
						var count = 0;
						for(var char = 0; char < checkForWords.length; ++char)
						{
							if(checkForWords.charAt(char) != '-')
							{
								word += checkForWords.charAt(char);
							}
							if(checkForWords.charAt(char) == '-' || char + 1 == checkForWords.length)
							{
								if(word.length >= 3)
								{
									wordsArray.push(word);
									count++;
								}
								word = "";
								continue;
							}
						} 
					}

					// Input: string of the drawn Letters
					// Output: true all letters of word are in the drawn letters, false if not
					function CWDcheckMatch(drawnLetters, word)
					{
						for(var i = 0; i < word.length; ++i)
						{
							if(drawnLetters.indexOf(word[i]) <= -1)
							{
								return false;
							}
						}
						return true; 
					}

					function Pot(prizeName) // Used in both MAT[3] and SYM[4]
					{						
						this.letter = prizeName;
						this.count = 0; 
					}
										
					function addToPotData(symbolPotData, letter) // Used in both MAT[3] and SYM[4]
					{
						for(var i = 0; i < symbolPotData.length; i++)
						{
							if(symbolPotData[i].letter.toString() === letter.toString())
							{
								symbolPotData[i].count = symbolPotData[i].count + 1;
								break;
							}
						}
						return symbolPotData; 
					}

					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								//registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
			 	</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" /> 
								<!-- <x:with-param name="value" select="my-ext:CWDfindWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 0)" /> -->
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" /> 
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" /> 
								<!-- <x:with-param name="value" select="my-ext:CWDfindWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 0)" /> -->
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" /> 
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template> 

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template> 

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template> 
</xsl:stylesheet>
