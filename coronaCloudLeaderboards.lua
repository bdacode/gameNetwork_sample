-- Copyright © 2013 Corona Labs Inc. All Rights Reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the company nor the names of its contributors
--      may be used to endorse or promote products derived from this software
--      without specific prior written permission.
--    * Redistributions in any form whatsoever must retain the following
--      acknowledgment visually in the program (e.g. the credits of the program): 
--      'This product includes software developed by Corona Labs Inc. (http://www.coronalabs.com).'
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL CORONA LABS INC. BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local leaderboards = {}

-- include the widget library
local widget = require "widget_orig"

leaderboards.userNameText = nil
leaderboards.delegate = nil
leaderboards.navFill = nil

leaderboards.show = function( responseObject, delegate )

--delegate.cc.getUserProfile("513e5e070fe8294912000001", delegate)

leaderboards.delegate = delegate
local responseObject = responseObject or {}

-- we read the display dimensions locally, since they change on orientation change
local DW = display.contentWidth
local DH = display.contentHeight

delegate._currentSection = 5
delegate.visible = true

local function onObjectTouch( event )
	
	local t = event.target
	if "began" == event.phase then
		t.active = true
		display.getCurrentStage():setFocus(t)
		
		for i = 1, delegate._leaderboardsDisplayGroup.numChildren do
			
			local child = delegate._leaderboardsDisplayGroup[ i ]
			if child.tag then
				if child.tag == event.target.tag then
					if child.type == "text" then
						child:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
					elseif child.type == "image" then
						child.alpha = 0.5 
					end
				end
			end
			
		end
		
	elseif "moved" == event.phase and t.active then
		if delegate._cloudHelper.isPointInside(t, event.x, event.y) then
		
		else
			for i = 1, delegate._leaderboardsDisplayGroup.numChildren do
				local child = delegate._leaderboardsDisplayGroup[ i ]
				if child.tag then
					if child.tag == event.target.tag then
						if child.type == "text" then
							child:setTextColor( unpack( delegate.conf.TITLE_COLOR ) )
						elseif child.type == "image" then
							child.alpha = 1.0
						end
					end
				end
			end
		end
	else
		display.getCurrentStage():setFocus(nil)
	end
	if "ended" == event.phase and t.active then
		t.active = false
		if delegate._cloudHelper.isPointInside(t, event.x, event.y) then
			
			for i = 1, delegate._leaderboardsDisplayGroup.numChildren do
				local child = delegate._leaderboardsDisplayGroup[ i ]
				if child and child.tag then
					if child.tag == event.target.tag then
						if child.type == "text" then
							child:setTextColor( unpack( delegate.conf.TITLE_COLOR ) )
						elseif child.type == "image" then
							child.alpha = 1.0
							if child.tag == delegate.conf.interfaceImages[ 1 ].tag then
								delegate.showDashboard()
								delegate._dashboardDisplayGroup.x = - DW + display.screenOriginX;
								transition.to (delegate._dashboardDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
								transition.to (delegate._leaderboardsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = DW - display.screenOriginX, onComplete = function()
									display.remove( delegate._leaderboardsDisplayGroup )
								end })
							end
							if child.tag == delegate.conf.interfaceImages[ 2 ].tag then
								leaderboards.hide()
							end
						end
					end
				end
			end
		end
	end
	
    return true
end

-- we remove the display group, so basically we make sure it's empty
display.remove( delegate._leaderboardsDisplayGroup )
delegate._leaderboardsDisplayGroup = display.newGroup()

if delegate._bg.isVisible == false then
	delegate._bg.isVisible = true
end

local viewFrame = display.newRoundedRect(delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.CORNER_RADIUS )
viewFrame:setReferencePoint(display.CenterReferencePoint)
viewFrame.strokeWidth = 2
viewFrame:setStrokeColor( unpack( delegate.conf.BORDER_COLOR ) )
viewFrame:setFillColor( 48, 48, 48, 255 )

-- top fill rectangle, 30 points tall
local topFill = display.newRoundedRect(delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.STATUSBAR_HEIGHT, delegate.conf.CORNER_RADIUS )
topFill:setReferencePoint( display.CenterReferencePoint )
topFill:setFillColor( unpack( delegate.conf.STATUSBAR_COLOR ) )
topFill.strokeWidth = 0

-- define a local coordinate which is equal to the underlap position + 15 (the height of the top fill). That's the point to start rendering the dashboard rectangles.
local currentY = topFill.y * 0.5 + delegate.conf.NAVBAR_HEIGHT

local bottomFill

if delegate._cloudHelper.isOrientationPortrait() then
	bottomFill = display.newRoundedRect( delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, currentY + 23, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.WINDOW_PADDING * 5 ) - 28, delegate.conf.CORNER_RADIUS )
	bottomFill:setReferencePoint( display.CenterReferencePoint )
	bottomFill:setFillColor( unpack( delegate.conf.NAVBAR_COLOR ) )
	bottomFill.strokeWidth = 0
else
	bottomFill = display.newRoundedRect( delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, currentY, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.WINDOW_PADDING * 5 ) - 5, delegate.conf.CORNER_RADIUS )
	bottomFill:setReferencePoint( display.CenterReferencePoint )
	bottomFill:setFillColor( unpack( delegate.conf.NAVBAR_COLOR ) )
	bottomFill.strokeWidth = 0
end

-- the tableview options
local listOptions

if delegate._cloudHelper.isOrientationPortrait() then

listOptions = {
        top = 150,
		left = 21,
        height = 302,
		width = 278,
		maskFile = "cloud_assets/mask-portrait.png",
		hideBackground = true
}

else
	
	listOptions = {
	        top = 127,
			left = 21,
	        height = 162,
			width = 438,
			maskFile = "cloud_assets/mask-320x366.png",
			hideBackground = true
	}
			
end

-- create the tableview
local list = widget.newTableView( listOptions )

delegate._leaderboardsDisplayGroup:insert( list )

local function noRowTouch( event )
	return true
end

-- onEvent listener for the tableView
local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view

        if event.phase == "press" then
                rowGroup.alpha = 0.7

        elseif event.phase == "swipeLeft" then
                --print( "Swiped left." )

        elseif event.phase == "swipeRight" then
                --print( "Swiped right." )

        elseif event.phase == "release" then
			delegate._currentLeaderboard = event.index
			delegate.showLeaderboardDetails( delegate._currentLeaderboard )
			delegate._leaderboardDetailsDisplayGroup.x = DW - display.screenOriginX
			transition.to (delegate._leaderboardDetailsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
			transition.to (delegate._leaderboardsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = - DW + display.screenOriginX, onComplete = function()
				display.remove( delegate._leaderboardsDisplayGroup )
			end })

        end

        return true
end

-- onRender listener for the tableView
local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
		local index = row.index

		-- the leaderboard name
		local achievementNameText = display.newText( responseObject[ index ][ "name" ] or "", 33, 18, delegate.conf.BOLD_FONT, 15 )
		rowGroup:insert( achievementNameText )
		achievementNameText:setReferencePoint( display.CenterLeftReferencePoint )
		achievementNameText.x = 33
		achievementNameText.y = 18 + delegate.conf.TEXT_BASELINE_CORRECTION
		achievementNameText:setTextColor( unpack( delegate.conf.TABLETEXT_COLOR ) )
		achievementNameText.type = "none"
		
		if delegate._cloudHelper.isOrientationPortrait() then
			achievementNameText.x = achievementNameText.x - 22
		end
		
		-- request the leaderboard details in the background
		if (responseObject[ index ]._id) then
			delegate.leaderboards.getScores( responseObject[ index ]._id, delegate )
		end
		
end

-- create the rows

-- if we have no rows, display a single row with the respective message.
if 0 == #responseObject then
	responseObject[ 1 ] = {}
	responseObject[ 1 ].name = delegate.conf.NO_LEADERBOARDS_TEXT 
end

for i=1,#responseObject do
        local rowHeight, rowColor, lineColor, isCategory

		rowHeight = 36
		
		if i % 2 == 0 then
			rowColor = { 221, 221, 221, 255 }
		else
			rowColor = { 191, 191, 191, 255 }
		end
		
        -- function below is responsible for creating the row
	if 0 == #responseObject then
        list:insertRow{
                onEvent=noRowTouch,
                onRender=onRowRender,
                height=rowHeight,
                isCategory=isCategory,
                rowColor=rowColor,
                lineColor=lineColor
        }
	else
		list:insertRow{
                onEvent=onRowTouch,
                onRender=onRowRender,
                height=rowHeight,
                isCategory=isCategory,
                rowColor=rowColor,
                lineColor=lineColor
        }
	end
end

leaderboards.navFill = display.newRect(delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, currentY, DW - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.NAVBAR_HEIGHT )
leaderboards.navFill:setReferencePoint( display.CenterReferencePoint )
leaderboards.navFill:setFillColor( unpack( delegate.conf.NAVBAR_COLOR ) )
leaderboards.navFill.strokeWidth = 0

if delegate._cloudHelper.isOrientationPortrait() then
	leaderboards.navFill.y = currentY + delegate.conf.NAVBAR_HEIGHT
end

-- draw the logo
local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
logoImage:setReferencePoint( display.CenterLeftReferencePoint )
delegate._leaderboardsDisplayGroup:insert( logoImage )
logoImage.x = delegate.conf.LOGO_PADDING[ 1 ]; logoImage.y = delegate.conf.LOGO_PADDING[ 2 ]
logoImage.xScale = delegate.conf.globalScale / 3.2; logoImage.yScale = delegate.conf.globalScale / 3.2
logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
logoImage.type = "image"
-- add the listener to the text
logoImage:addEventListener( "touch", onObjectTouch )

if delegate._cloudHelper.isOrientationPortrait() then
	logoImage.y = logoImage.y + 13
end

local topSeparator = display.newRoundedRect(delegate._leaderboardsDisplayGroup, logoImage.x + logoImage.contentWidth * 1.5, delegate.conf.LOGO_PADDING[ 2 ] * 0.5 + 1, 1, logoImage.contentHeight + 6, 1 )
topSeparator:setReferencePoint( display.CenterReferencePoint )
topSeparator:setFillColor( unpack( delegate.conf.TOPSEP_COLOR ) )
topSeparator.strokeWidth = 0

-- draw the user profile
-- todo: add the actual profile picture from the cloud
--local userImageHolder = display.newRoundedRect( delegate._leaderboardsDisplayGroup, topSeparator.x + 10, topSeparator.y, 40, 40, 5 )
--userImageHolder:setReferencePoint( display.CenterReferencePoint )
--userImageHolder.y = topSeparator.y
--userImageHolder:setFillColor( 255, 255, 255, 255 )
--userImageHolder.strokeWidth = 2
--userImageHolder:setStrokeColor( unpack( delegate.conf.PROFILE_STROKE_COLOR ) )

-- draw the username text
local theUserName = leaderboards.delegate._cache._userCache.username or "Corona User"

--leaderboards.usernameText = display.newText(delegate._achievementsDisplayGroup, theUserName, userImageHolder.x + userImageHolder.contentWidth * 0.5 + 10, ( userImageHolder.yOrigin - userImageHolder.contentHeight / 2 ) + 15, delegate.conf.BOLD_FONT, 16 )
leaderboards.usernameText = display.newText(delegate._leaderboardsDisplayGroup, theUserName, topSeparator.x + 10, topSeparator.y + delegate.conf.TEXT_BASELINE_CORRECTION, delegate.conf.BOLD_FONT, 16 )
leaderboards.usernameText:setReferencePoint( display.CenterLeftReferencePoint )
leaderboards.usernameText.y = topSeparator.y - 10 + delegate.conf.TEXT_BASELINE_CORRECTION
leaderboards.usernameText:setTextColor( unpack( delegate.conf.TITLE_COLOR ) )

local currentX = leaderboards.usernameText.xOrigin - leaderboards.usernameText.contentWidth * 0.5 + 8
local profileY = leaderboards.usernameText.yOrigin + leaderboards.usernameText.contentHeight / 2 + 8

if delegate._cloudHelper.isOrientationPortrait() then
	profileY = profileY + 27
	currentX = currentX - 3
end

-- add the bottom bar with the four icons.
for i = 1, #delegate.conf.profileEnabledFeatures do
	
	local currentFeature = delegate.conf.profileEnabledFeatures [ i ]

	-- create the feature image
	local featureImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( currentFeature.icon ))
	featureImage:setReferencePoint( display.CenterReferencePoint )
	delegate._leaderboardsDisplayGroup:insert( featureImage )
	featureImage.x = currentX; featureImage.y = profileY
	featureImage.xScale = delegate.conf.globalScale / 2; featureImage.yScale = delegate.conf.globalScale / 2
	featureImage.tag = currentFeature.tag
	-- add the listener to the image
	featureImage:addEventListener( "touch", onObjectTouch )
	featureImage.type = "none"
	
	local displayedText = ""
	if i == 1 then
	-- friends
	displayedText = #delegate._cache._friendsCache or 0
	elseif i == 2 then
	-- news
	local numNews = 0
	if delegate._cache._newsCache then
		for i = 1, #delegate._cache._newsCache do
			if delegate._cache._newsCache[ i ].is_unread == true then
				numNews = numNews + 1
			end
		end
	end
	
	displayedText = numNews
	end

	-- create the feature text to be displayed on the dashboard
	local featureText = display.newText(delegate._leaderboardsDisplayGroup,  displayedText, featureImage.x + featureImage.contentWidth / 2, featureImage.y, delegate.conf.MAIN_FONT, 13 )
	featureText:setReferencePoint( display.CenterLeftReferencePoint )
	featureText.y = featureImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
	featureText:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
	featureText.tag = currentFeature.tag
	featureText.type = "none"
	-- add the listener to the text
	featureText:addEventListener( "touch", onObjectTouch )	
	
	currentX = currentX + featureImage.contentWidth + featureText.contentWidth + 10	


	
end

-- the vertical bar next to the user points
local topSeparator = display.newRoundedRect (delegate._leaderboardsDisplayGroup, 340, 56, 1.5, 24, 1)
topSeparator:setFillColor ( unpack( delegate.conf.TOPSEP_COLOR ) )

if delegate._cloudHelper.isOrientationPortrait() then
	topSeparator.alpha = 0
end

-- the corona icon
local coronaIcon = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
coronaIcon:setReferencePoint( display.CenterReferencePoint )
delegate._leaderboardsDisplayGroup:insert( coronaIcon )
coronaIcon.x = topSeparator.x + topSeparator.contentWidth + 18; coronaIcon.y = 68
coronaIcon.xScale = delegate.conf.globalScale / 8; coronaIcon.yScale = delegate.conf.globalScale / 8
coronaIcon.tag = delegate.conf.interfaceImages[ 1 ].tag

if delegate._cloudHelper.isOrientationPortrait() then
	coronaIcon.x = leaderboards.usernameText.x + 8
end

local scoreNumber = delegate._cache._userCache.points or 0
local input = scoreNumber
local input2 = string.gsub(input, "(%d)(%d%d%d)$", "%1,%2", 1)
local found
while true do
    input2, found = string.gsub(input2, "(%d)(%d%d%d),", "%1,%2,", 1)
    if found == 0 then break end
end

local globalScoreText = display.newText( input2, 0, 0, delegate.conf.BOLDC_FONT, 20 )
delegate._leaderboardsDisplayGroup:insert( globalScoreText )
globalScoreText:setReferencePoint( display.CenterLeftReferencePoint )
globalScoreText.x = coronaIcon.x + coronaIcon.contentWidth - 2
globalScoreText.y = coronaIcon.y + delegate.conf.TEXT_BASELINE_CORRECTION
globalScoreText:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
globalScoreText.type = "none"



-- draw the elements on the navfill
local gameImageHolder = display.newRoundedRect( delegate._leaderboardsDisplayGroup, 53, leaderboards.navFill.y - 15, 30, 30, 3 )
gameImageHolder:setReferencePoint( display.CenterReferencePoint )
gameImageHolder:setFillColor( 0, 0, 0, 255 )
gameImageHolder.strokeWidth = 1
gameImageHolder:setStrokeColor( unpack( delegate.conf.PROFILE_STROKE_COLOR ) )

if delegate._cloudHelper.isOrientationPortrait() then
	gameImageHolder.x = 46
end

-- we read the image, if it exists
local function networkImageListener( event )
	local target = event.target
        if ( event.isError ) then
                -- error
        else
                target.alpha = 1.0
                target.width = 30
				target.height = 30
				target:setReferencePoint( display.CenterReferencePoint )
				target.y = gameImageHolder.y
				target.x = gameImageHolder.x
				if delegate._leaderboardsDisplayGroup and leaderboards.navFill then
				delegate._leaderboardsDisplayGroup:insert( target )
				else
				target.alpha = 0
				end
				
				-- redraw the gameImageholder on top
				local gameImageHolder = display.newRoundedRect( delegate._leaderboardsDisplayGroup, 53, leaderboards.navFill.y - 15, 30, 30, 3 )
				gameImageHolder:setReferencePoint( display.CenterReferencePoint )
				gameImageHolder:setFillColor( 0, 0, 0, 0 )
				gameImageHolder.strokeWidth = 1
				gameImageHolder:setStrokeColor( unpack( delegate.conf.PROFILE_STROKE_COLOR ) )
				if delegate._cloudHelper.isOrientationPortrait() then
					gameImageHolder.x = 46
				end
        end
end

if delegate._cache._infoCache.logo_url then
		display.loadRemoteImage( delegate._cache._infoCache.logo_url, "GET", networkImageListener, "gameLogo.png", system.TemporaryDirectory, 50, 50 )
end

local gameName = delegate._cache._infoCache.name or ""

-- the game name
local gameNameText = display.newText(delegate._leaderboardsDisplayGroup,  gameName, gameImageHolder.x + gameImageHolder.contentWidth, leaderboards.navFill.y , delegate.conf.BOLD_FONT, 18 )
gameNameText:setReferencePoint( display.CenterLeftReferencePoint )
gameNameText.y = leaderboards.navFill.y + delegate.conf.TEXT_BASELINE_CORRECTION
gameNameText:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
gameNameText.type = "none"

if delegate._cloudHelper.isOrientationPortrait() then
	gameNameText.x = gameNameText.x - 8
end

-- the horizontal bar next to the game name
local gameSeparator = display.newRoundedRect (delegate._leaderboardsDisplayGroup, gameNameText.x + gameNameText.contentWidth + 15, gameImageHolder.y - gameImageHolder.contentHeight * 0.5 - 2, 1.5, 36, 1)
gameSeparator:setFillColor ( unpack( delegate.conf.NAVSEP_COLOR ) )

if delegate._cloudHelper.isOrientationPortrait() then
	gameSeparator.x = gameSeparator.x - 8
end

-- the achievements icon
local achievementsIcon = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 6 ].icon ))
achievementsIcon:setReferencePoint( display.CenterReferencePoint )
delegate._leaderboardsDisplayGroup:insert( achievementsIcon )
achievementsIcon.x = gameSeparator.x + gameSeparator.contentWidth + 25; achievementsIcon.y = gameImageHolder.y
achievementsIcon.xScale = delegate.conf.globalScale; achievementsIcon.yScale = delegate.conf.globalScale
achievementsIcon.tag = delegate.conf.interfaceImages[ 5 ].tag

if delegate._cloudHelper.isOrientationPortrait() then
	achievementsIcon.x = achievementsIcon.x - 8
end	

-- the achievements text
local screenNameText = display.newText(delegate._leaderboardsDisplayGroup,  "LEADERBOARDS", achievementsIcon.x + achievementsIcon.contentWidth - 10, leaderboards.navFill.y , delegate.conf.COND_FONT, 15 )
screenNameText:setReferencePoint( display.CenterLeftReferencePoint )
screenNameText.y = leaderboards.navFill.y + delegate.conf.TEXT_BASELINE_CORRECTION
screenNameText:setTextColor( 255, 255, 255, 255 )
screenNameText.type = "none"

if delegate._cloudHelper.isOrientationPortrait() then
	screenNameText.x = screenNameText.x - 6
end	


-- the overlay frame
local viewFrameOverlay = display.newRoundedRect(delegate._leaderboardsDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.CORNER_RADIUS )
viewFrameOverlay:setReferencePoint(display.CenterReferencePoint)
viewFrameOverlay.strokeWidth = 2
viewFrameOverlay:setStrokeColor( unpack( delegate.conf.BORDER_COLOR ) )
viewFrameOverlay:setFillColor( 0, 0, 0, 0 )

-- bring the texts and images to front
for i = 1, delegate._leaderboardsDisplayGroup.numChildren do
	local child = delegate._leaderboardsDisplayGroup[ i ]
	if child.tag then
		if child.tag >= 1000 and child.tag <= 1010 then
			child:toFront()
		end
	end
end 

-- draw the close button
local closeButton = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 2 ].icon ))
closeButton:setReferencePoint( display.CenterReferencePoint )
delegate._leaderboardsDisplayGroup:insert( closeButton )
closeButton.x = DW - delegate.conf.CORNER_UNDERLAP - 7; closeButton.y = delegate.conf.CORNER_UNDERLAP + 7
closeButton.xScale = delegate.conf.globalScale; closeButton.yScale = delegate.conf.globalScale
closeButton.tag = delegate.conf.interfaceImages[ 2 ].tag
closeButton:addEventListener( "touch", onObjectTouch )
closeButton.type = "image"

end

leaderboards.hide = function()
	leaderboards.delegate._currentSection = 0
	leaderboards.delegate.visible = false
	display.remove( leaderboards.delegate._leaderboardsDisplayGroup )
	leaderboards.delegate._bg.isVisible = false
end

return leaderboards