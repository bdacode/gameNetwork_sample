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

local coronaCloudDashboard = {}

-- include the widget library
local widget = require "widget_orig"
coronaCloudDashboard.delegate = nil

coronaCloudDashboard.show = function( delegate )
	coronaCloudDashboard.delegate = delegate
	delegate._currentSection = 1
	delegate.visible = true
	
		
	-- we read the display dimensions locally, since they change on orientation change
	local DW = display.contentWidth
	local DH = display.contentHeight
	
	local function onObjectTouch( event )
		local t = event.target
		if "began" == event.phase then
			t.active = true
			display.getCurrentStage():setFocus(t)
			
			for i = 1, delegate._dashboardDisplayGroup.numChildren do
				
				local child = delegate._dashboardDisplayGroup[ i ]
				if child.tag then
					if child.tag == t.tag then
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
				for i = 1, delegate._dashboardDisplayGroup.numChildren do
					local child = delegate._dashboardDisplayGroup[ i ]
					if child.tag then
						if child.tag == t.tag then
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
				
				for i = 1, delegate._dashboardDisplayGroup.numChildren do
					local child = delegate._dashboardDisplayGroup[ i ]
					if child.tag then
						if child.tag == t.tag then
							if child.type == "text" then
								child:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
								-- achievements
								if child.tag == 1000 then
									delegate.showAchievements( {}, delegate )
									delegate._achievementsDisplayGroup.x = DW - display.screenOriginX
									transition.to (delegate._achievementsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
									transition.to (delegate._dashboardDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = -DW + display.screenOriginX , onComplete = function()
										display.remove( delegate._dashboardDisplayGroup )
									end })
								-- leaderboards
								elseif child.tag == 1003 then
									delegate.showLeaderboards( {}, delegate )
									delegate._leaderboardsDisplayGroup.x = DW - display.screenOriginX
									transition.to (delegate._leaderboardsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
									transition.to (delegate._dashboardDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = -DW + display.screenOriginX , onComplete = function()
										display.remove( delegate._dashboardDisplayGroup )
									end })	
									-- friends
									elseif child.tag == 1001 then
										delegate.showFriends( {}, delegate )
										delegate._friendsDisplayGroup.x = DW - display.screenOriginX
										transition.to (delegate._friendsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
										transition.to (delegate._dashboardDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = -DW + display.screenOriginX , onComplete = function()
											display.remove( delegate._dashboardDisplayGroup )
										end })						
									elseif child.tag == 1006 then
										delegate.showNews( delegate )
										delegate._newsDisplayGroup.x = DW - display.screenOriginX
										transition.to (delegate._newsDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = 0})
										transition.to (delegate._dashboardDisplayGroup, {time = delegate.conf.TRANSITION_TIME, x = -DW + display.screenOriginX , onComplete = function()
											display.remove( delegate._dashboardDisplayGroup )
										end })						
									end

							elseif child.type == "image" then
								child.alpha = 1.0
								if child.tag == delegate.conf.interfaceImages[ 2 ].tag then
									coronaCloudDashboard.hide()
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
	display.remove( delegate._dashboardDisplayGroup )
	delegate._dashboardDisplayGroup = display.newGroup()
	
	if delegate._bg.isVisible == false then
		delegate._bg.isVisible = true
	end
	
	local viewFrame = display.newRoundedRect(delegate._dashboardDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.
	WINDOW_PADDING * 2 ), delegate.conf.CORNER_RADIUS )
	viewFrame:setReferencePoint(display.CenterReferencePoint)
	viewFrame.strokeWidth = 2
	viewFrame:setStrokeColor( unpack( delegate.conf.BORDER_COLOR ) )
	viewFrame:setFillColor( 48, 48, 48, 255 )

	-- top fill rectangle, 30 points tall
	local topFill = display.newRoundedRect(delegate._dashboardDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.SEPARATOR_HEIGHT * 4, delegate.conf.CORNER_RADIUS )
	topFill:setReferencePoint( display.CenterReferencePoint )
	topFill:setFillColor( unpack( delegate.conf.SUB_COLOR ) )
	topFill.strokeWidth = 0

	-- and the bottom one
	local bottomFill = display.newRoundedRect(delegate._dashboardDisplayGroup, delegate.conf.WINDOW_PADDING, DH - delegate.conf.WINDOW_PADDING  - delegate.conf.SEPARATOR_HEIGHT * 4, DW - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.SEPARATOR_HEIGHT * 4, delegate.conf.CORNER_RADIUS )
	bottomFill:setFillColor( unpack( delegate.conf.SUB_COLOR ) )
	bottomFill.strokeWidth = 0

	-- do all the interface elements
	
	-- define a local coordinate which is equal to the underlap position + 15 (the height of the top fill). That's the point to start rendering the dashboard rectangles.
	local currentY = delegate.conf.CORNER_UNDERLAP + 15
	-- cache the number of enabled features
	
	-- the y increase unit, given by the number of points available on the display divided by the number of enabled cloud features
	
	-- get the bottomPosition and the topPosition
	local bottomPosition = bottomFill.y + delegate.conf.SEPARATOR_HEIGHT
	local topPosition = topFill.y - delegate.conf.SEPARATOR_HEIGHT
	
	-- calculate the increase unit in pixels of the Y coordonate, while rendering
	local increaseUnit = math.floor ( ( bottomPosition - topPosition ) / #delegate.conf.enabledFeatures )
	
	-- loop through the enabled features in the config
	for i = 1, #delegate.conf.enabledFeatures do
		
		local currentFeature = delegate.conf.enabledFeatures [ i ]
		
		-- local variable we use for the base x coordinate of the icons / texts
		local centerX = DW * 0.5

		if delegate._cloudHelper.isOrientationPortrait() then
			centerX = delegate.conf.CORNER_UNDERLAP + delegate.conf.PADDING_LEFT + 15
		end

		-- create the background fill, with the two colors we use.
		local featureFill = display.newRect( delegate._dashboardDisplayGroup, delegate.conf.CORNER_UNDERLAP, currentY, DW - 42, increaseUnit )
		if i % 2 ~= 0 then
			featureFill:setFillColor( unpack( delegate.conf.BASE_COLOR ) )
		else
			featureFill:setFillColor( unpack( delegate.conf.SUB_COLOR ) )	
		end

		-- create the feature image
		local featureImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( currentFeature.icon ))
		featureImage:setReferencePoint( display.CenterReferencePoint )
		delegate._dashboardDisplayGroup:insert( featureImage )
		featureImage.x = centerX; featureImage.y = featureFill.y
		featureImage.xScale = delegate.conf.globalScale; featureImage.yScale = delegate.conf.globalScale
		featureImage.tag = currentFeature.tag
		-- add the listener to the image
		featureImage:addEventListener( "touch", onObjectTouch )
		featureImage.type = "image"

		-- create the feature text to be displayed on the dashboard
		local featureText = display.newText(delegate._dashboardDisplayGroup,  currentFeature.description, featureImage.x + featureImage.contentWidth, featureFill.y, delegate.conf.MAIN_FONT, 18 )
		featureText:setReferencePoint( display.CenterReferencePoint )
		featureText.y = featureFill.y + delegate.conf.TEXT_BASELINE_CORRECTION
		featureText:setTextColor( unpack( delegate.conf.TITLE_COLOR ) )
		featureText.tag = currentFeature.tag
		featureText.type = "text"
		-- add the listener to the text
		featureText:addEventListener( "touch", onObjectTouch )		
		
		-- increase the positioning counter		
		currentY = currentY + increaseUnit

	end
	
	-- draw the logo
	local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
	logoImage:setReferencePoint( display.CenterLeftReferencePoint )
	delegate._dashboardDisplayGroup:insert( logoImage )
	logoImage.x = delegate.conf.CORNER_UNDERLAP + delegate.conf.PADDING_LEFT; logoImage.y = DH * 0.5
	logoImage.xScale = delegate.conf.globalScale; logoImage.yScale = delegate.conf.globalScale
	logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
	
	-- if we're on portrait, do the image at lower alpha
	if delegate._cloudHelper.isOrientationPortrait() then
		logoImage:setReferencePoint( display.CenterReferencePoint )
		logoImage.alpha = 0.25
		logoImage.x = DW * 0.5
	end
	
	-- the overlay frame
	local viewFrameOverlay = display.newRoundedRect(delegate._dashboardDisplayGroup, delegate.conf.WINDOW_PADDING, delegate.conf.WINDOW_PADDING, DW - ( delegate.conf.WINDOW_PADDING * 2 ), DH - ( delegate.conf.WINDOW_PADDING * 2 ), delegate.conf.CORNER_RADIUS )
	viewFrameOverlay:setReferencePoint(display.CenterReferencePoint)
	viewFrameOverlay.strokeWidth = 2
	viewFrameOverlay:setStrokeColor( unpack( delegate.conf.BORDER_COLOR ) )
	viewFrameOverlay:setFillColor( 0, 0, 0, 0 )

	-- bring the texts and images to front
	for i = 1, delegate._dashboardDisplayGroup.numChildren do
		local child = delegate._dashboardDisplayGroup[ i ]
		if child.tag then
			if child.tag >= 1000 and child.tag <= 1010 then
				child:toFront()
			end
		end
	end 
	
	-- draw the close button
	local closeButton = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 2 ].icon ))
	closeButton:setReferencePoint( display.CenterReferencePoint )
	delegate._dashboardDisplayGroup:insert( closeButton )
	closeButton.x = DW - delegate.conf.CORNER_UNDERLAP - 7; closeButton.y = delegate.conf.CORNER_UNDERLAP + 7
	closeButton.xScale = delegate.conf.globalScale; closeButton.yScale = delegate.conf.globalScale
	closeButton.tag = delegate.conf.interfaceImages[ 2 ].tag
	closeButton:addEventListener( "touch", onObjectTouch )
	closeButton.type = "image"
	
end

coronaCloudDashboard.hide = function()
	coronaCloudDashboard.delegate._currentSection = 0
	coronaCloudDashboard.delegate.visible = false
	display.remove( coronaCloudDashboard.delegate._dashboardDisplayGroup )
	coronaCloudDashboard.delegate._bg.isVisible = false
end

return coronaCloudDashboard