--
-- Abstract: Corona Cloud UI Sample Application
--
-- Date: March 19, 2013
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Author: Corona Labs
--
-- Demonstrates: corona cloud, gameNetwork UI
--
-- File dependencies: none
--
-- Target devices: devices and simulator
--
-- Update History:
--	N/A
--
-- Comments: 
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2013 Corona Labs Inc. All Rights Reserved.
---------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- require gameNetwork
local gameNetwork = require( "gameNetwork_corona_prototype" )

-- forward reference to the buttons
local dashboardButton, achievementsButton, leaderboardsButton, unlockButton, highscoreButton

-- touch listener for the push button
local function buttonPressed( event )
	
	local target = event.target
	
	if event.phase == "began" then
		target:setTextColor( 245, 127, 32 )
	elseif event.phase == "ended" then
		-- switch the tags and take appropriate action
		if target.tag == 1 then
			gameNetwork.show("dashboard")
		elseif target.tag == 2 then
			gameNetwork.show("achievements")
		elseif target.tag == 3 then
			gameNetwork.show("leaderboards")
		elseif target.tag == 4 then
			gameNetwork.show("unlock_achievement", { "Reached 10 points!", "10" } )
		elseif target.tag == 5 then
			gameNetwork.show("post_highscore", { "1000" } )
		end
		-- reset the button color after triggering the action
		target:setTextColor( 97, 97, 97 )
	end
end

-- calculate the scale
local globalScale = 1
-- for most devices with scaling values between 0.6 and 0.25, we're talking about a retina device, non-tablet
if display.contentScaleX <= 0.6 then
	globalScale = 0.5
end

-- init the corona cloud with your access key and secret key
local params = {}
params.accessKey = "MY_ACCESS_KEY_HERE"
params.secretKey = "MY_SECRET_KEY_HERE"
params.supportedOrientations = { "portrait", "portraitUpsideDown", "landscapeLeft", "landscapeRight" }
params.facebookApplicationId = "MY_FACEBOOK_APP_ID_HERE"

gameNetwork.init( "corona", params )

local theGroup = display.newGroup()

-- background image
local backgroundImage = display.newImage ( "background.png", display.contentWidth, display.contentHeight )
backgroundImage.x = display.contentWidth * 0.5
backgroundImage.y = display.contentHeight * 0.5
backgroundImage.xScale = globalScale; backgroundImage.yScale = globalScale
theGroup:insert( backgroundImage )

-- corona logo
local logoImage = display.newImage( "Icon-xhdpi.png", 96, 96 )
logoImage:setReferencePoint( display.CenterReferencePoint )
logoImage.x = 50
logoImage.y = 60
logoImage.xScale = globalScale; logoImage.yScale = globalScale

-- sample text
local myText = display.newText("GameNetwork UI", 140, logoImage.y - logoImage.contentHeight * 0.3, "Futura-Medium", 20)
myText:setTextColor( 0, 0, 0 )

-- dashboard button
dashboardButton = display.newText( "SHOW DASHBOARD", display.contentWidth * 0.5, display.contentHeight - 360, "Futura-CondensedExtraBold", 20 )
dashboardButton:setReferencePoint( display.CenterReferencePoint )
dashboardButton.x = display.contentWidth * 0.5
dashboardButton:setTextColor( 97, 97, 97 )
dashboardButton.tag = 1
dashboardButton:addEventListener( "touch", buttonPressed )

-- achievements button
achievementsButton = display.newText( "SHOW ACHIEVEMENTS", display.contentWidth * 0.5, display.contentHeight - 300, "Futura-CondensedExtraBold", 20 )
achievementsButton:setReferencePoint( display.CenterReferencePoint )
achievementsButton.x = display.contentWidth * 0.5
achievementsButton:setTextColor( 97, 97, 97 )
achievementsButton.tag = 2
achievementsButton:addEventListener( "touch", buttonPressed )

-- leaderboards button
leaderboardsButton = display.newText( "SHOW LEADERBOARDS", display.contentWidth * 0.5, display.contentHeight - 240, "Futura-CondensedExtraBold", 20 )
leaderboardsButton:setReferencePoint( display.CenterReferencePoint )
leaderboardsButton.x = display.contentWidth * 0.5
leaderboardsButton:setTextColor( 97, 97, 97 )
leaderboardsButton.tag = 3
leaderboardsButton:addEventListener( "touch", buttonPressed )

-- unlock achievement button
unlockButton = display.newText( "UNLOCK ACHIEVEMENT", display.contentWidth * 0.5, display.contentHeight - 180, "Futura-CondensedExtraBold", 20 )
unlockButton:setReferencePoint( display.CenterReferencePoint )
unlockButton.x = display.contentWidth * 0.5
unlockButton:setTextColor( 97, 97, 97 )
unlockButton.tag = 4
unlockButton:addEventListener( "touch", buttonPressed )

-- post highscore button
highscoreButton = display.newText( "POST HIGHSCORE", display.contentWidth * 0.5, display.contentHeight - 120, "Futura-CondensedExtraBold", 20 )
highscoreButton:setReferencePoint( display.CenterReferencePoint )
highscoreButton.x = display.contentWidth * 0.5
highscoreButton:setTextColor( 97, 97, 97 )
highscoreButton.tag = 5
highscoreButton:addEventListener( "touch", buttonPressed )




