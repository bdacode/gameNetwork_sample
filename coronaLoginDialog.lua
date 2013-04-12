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

local loginDialog = {}

local widget = require "widget_orig"

-- delegate, used for hiding the view
loginDialog._delegate = nil

loginDialog.show = function( delegate )

loginDialog._delegate = delegate

loginDialog._usernameText = nil
loginDialog._passwordText = nil
loginDialog._userName = nil
loginDialog._password = nil

delegate._currentSection = 11
delegate.visible = true

-- we read the display dimensions locally, since they change on orientation change
local DW = display.contentWidth
local DH = display.contentHeight

display.remove( delegate._loginDisplayGroup )
delegate._loginDisplayGroup = display.newGroup()
delegate._loginDisplayGroup.x = 0
if delegate._bg.isVisible == false then
	delegate._bg.isVisible = true
end

local popupFrame

if delegate._cloudHelper.isOrientationPortrait() then

	popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING, 20, DW - ( delegate.conf.WINDOW_PADDING * 2 ), 200 , delegate.conf.CORNER_RADIUS )

else

	popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING + 40, 20, DW - ( delegate.conf.WINDOW_PADDING * 2 ) - 80, 170 , delegate.conf.CORNER_RADIUS )
	
end

popupFrame:setReferencePoint(display.CenterReferencePoint)
popupFrame.strokeWidth = 5
popupFrame:setStrokeColor( 255, 255, 255, 255 )
popupFrame:setFillColor( 0, 0, 0, 200 )

-- draw the logo
local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
logoImage:setReferencePoint( display.CenterLeftReferencePoint )
delegate._loginDisplayGroup:insert( logoImage )
logoImage.x = delegate.conf.LOGO_PADDING[ 1 ] + 35; logoImage.y = delegate.conf.LOGO_PADDING[ 2 ] + 5
logoImage.xScale = delegate.conf.globalScale / 4; logoImage.yScale = delegate.conf.globalScale / 4
logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
logoImage.type = "image"
if delegate._cloudHelper.isOrientationPortrait() then
	logoImage.x = logoImage.x - 40; logoImage.y = logoImage.y + 10
end


local loginHeaderText = display.newText( "Login" , 130, 11, delegate.conf.BOLD_FONT, 20 )
delegate._loginDisplayGroup:insert( loginHeaderText )
loginHeaderText:setReferencePoint( display.CenterLeftReferencePoint )
loginHeaderText.y = logoImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
loginHeaderText:setTextColor( 237, 28, 36, 255 )
if delegate._cloudHelper.isOrientationPortrait() then
	loginHeaderText.x = loginHeaderText.x - 40
end

local guestText = display.newText( "Email:" , 130, 11, delegate.conf.REGULAR_FONT, 16 )
delegate._loginDisplayGroup:insert( guestText )
guestText:setReferencePoint( display.CenterLeftReferencePoint )
guestText.y = loginHeaderText.y + 30 + delegate.conf.TEXT_BASELINE_CORRECTION
guestText:setTextColor( 255, 255, 255, 255 )
if delegate._cloudHelper.isOrientationPortrait() then
	guestText.x = guestText.x - 75
	guestText.y = guestText.y + 20
end

local passText = display.newText( "Password:" , 102, 11, delegate.conf.REGULAR_FONT, 16 )
delegate._loginDisplayGroup:insert( passText )
passText:setReferencePoint( display.CenterLeftReferencePoint )
passText.y = loginHeaderText.y + 70 + delegate.conf.TEXT_BASELINE_CORRECTION
passText:setTextColor( 255, 255, 255, 255 )
if delegate._cloudHelper.isOrientationPortrait() then
	passText.x = passText.x - 75
	passText.y = passText.y + 20
end

local function usernameHandler( event )
	if ( "began" == event.phase ) then
	elseif ( "ended" == event.phase ) then
		loginDialog._userName = loginDialog._usernameText.text
		native.setKeyboardFocus( nil )
	elseif ( "submitted" == event.phase ) then
		loginDialog._userName = loginDialog._usernameText.text
		native.setKeyboardFocus( nil )
	end
end

local function backgroundHandler( event )
	if ( "ended" == event.phase ) then
		native.setKeyboardFocus( nil )
		loginDialog._userName = loginDialog._usernameText.text
		loginDialog._password = loginDialog._passwordText.text
	end
end

local function passwordHandler( event )
	if ( "began" == event.phase ) then
	elseif ( "ended" == event.phase ) then
		loginDialog._password = loginDialog._passwordText.text
		native.setKeyboardFocus( nil )
	elseif ( "submitted" == event.phase ) then
		loginDialog._password = loginDialog._passwordText.text
		native.setKeyboardFocus( nil )
	end
end

delegate._loginDisplayGroup:addEventListener("touch", backgroundHandler )
delegate._bg:addEventListener("touch", backgroundHandler )

loginDialog._usernameText = native.newTextField( 180, 78, 180, 30 )
loginDialog._usernameText:addEventListener("userInput", usernameHandler)

loginDialog._passwordText = native.newTextField( 180, 118, 180, 30 )
loginDialog._passwordText.isSecure = true
loginDialog._passwordText:addEventListener("userInput", passwordHandler)

if delegate._cloudHelper.isOrientationPortrait() then
	loginDialog._usernameText.x = loginDialog._usernameText.x - 75
	loginDialog._usernameText.y = loginDialog._usernameText.y + 30
end

if delegate._cloudHelper.isOrientationPortrait() then
	loginDialog._passwordText.x = loginDialog._passwordText.x - 75
	loginDialog._passwordText.y = loginDialog._passwordText.y + 30
end

-- the close button
local closeButton = widget.newButton{
    id = "closeButton",
    left = popupFrame.x + popupFrame.width * 0.5 - 40,
    top = 30,
    width = 28, height = 28,
    sheet = delegate.conf.cloudSheet,
	defaultIndex = delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 10 ].icon ),
	overIndex = delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 10 ].icon ),
    onRelease = loginDialog.close
}
delegate._loginDisplayGroup:insert( closeButton )
if delegate._cloudHelper.isOrientationPortrait() then
	closeButton.y = closeButton.y
end

local function onObjectTouch( event )
	local t = event.target
	if "began" == event.phase then
		t.active = true
		display.getCurrentStage():setFocus(t)
		
		for i = 1, delegate._loginDisplayGroup.numChildren do
			
			local child = delegate._loginDisplayGroup[ i ]
			if child.tag then
				if child.tag == t.tag then
					if child.type == "text" then
						child:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )
					end
				end
			end
			
		end
		
	elseif "moved" == event.phase and t.active then
		if delegate._cloudHelper.isPointInside(t, event.x, event.y) then
		
		else
			for i = 1, delegate._loginDisplayGroup.numChildren do
				local child = delegate._loginDisplayGroup[ i ]
				if child.tag then
					if child.tag == t.tag then
						if child.type == "text" then
							child:setTextColor( 255, 255, 255, 255 )
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
			
			for i = 1, delegate._loginDisplayGroup.numChildren do
				local child = delegate._loginDisplayGroup[ i ]
				if child.tag then
					if child.tag == t.tag then
						if child.type == "text" then
							child:setTextColor( 255, 255, 255, 255 )
							-- login
							if child.tag == 5000 then
								loginDialog.authenticateUser()
							end
						end
					end
				end
			end
		end
	end
	
	return true 
end

local confirmButton = display.newText( "Login", popupFrame.x + popupFrame.width * 0.5 - 40, popupFrame.y + popupFrame.height * 0.5 - 40, delegate.conf.BOLD_FONT, 20)
delegate._loginDisplayGroup:insert( confirmButton )
confirmButton:setReferencePoint( display.CenterLeftReferencePoint )
confirmButton.y = popupFrame.y + popupFrame.height * 0.5 - 25 + delegate.conf.TEXT_BASELINE_CORRECTION
confirmButton.x = popupFrame.x + popupFrame.width * 0.5 - 65
confirmButton:setTextColor( 255, 255, 255, 255 )
confirmButton.type = "text"
confirmButton.tag = 5000
confirmButton:addEventListener( "touch", onObjectTouch )

end

loginDialog.authenticateUser = function()
	loginDialog._userName = loginDialog._usernameText.text
	loginDialog._password = loginDialog._passwordText.text
	if not loginDialog._userName or loginDialog._userName == "" then
		local alert = native.showAlert( "Corona Cloud", "Please enter your username.", { "OK" } )
	elseif not loginDialog._password or loginDialog._password == "" then
		local alert = native.showAlert( "Corona Cloud", "Please enter your password.", { "OK" } )
	else
		loginDialog._delegate._pass = loginDialog._password
		loginDialog._delegate.authenticateUser( loginDialog._userName, loginDialog._password )
	end
end

loginDialog.hide = function()
	if loginDialog._delegate then
		loginDialog._delegate._currentSection = 0
		loginDialog._delegate.visible = false
		if nil ~= loginDialog._usernameText and loginDialog._usernameText.isVisible then
			loginDialog._usernameText:removeSelf()
		end
		if nil ~= loginDialog._passwordText and loginDialog._passwordText.isVisible then
			loginDialog._passwordText:removeSelf()
		end
		display.remove( loginDialog._delegate._loginDisplayGroup )
	end
end

loginDialog.close = function()
		loginDialog._delegate._currentSection = 0
		loginDialog._delegate.visible = false
		if nil ~= loginDialog._usernameText and loginDialog._usernameText.isVisible then
			loginDialog._usernameText:removeSelf()
		end
		if nil ~= loginDialog._passwordText and loginDialog._passwordText.isVisible then
			loginDialog._passwordText:removeSelf()
		end
		display.remove( loginDialog._delegate._loginDisplayGroup )
		loginDialog._delegate.showWelcomeDialog()
end

loginDialog.cleanTexts = function()
	if nil ~= loginDialog._usernameText and loginDialog._usernameText.isVisible then
		loginDialog._usernameText:removeSelf()
	end
	if nil ~= loginDialog._passwordText and loginDialog._passwordText.isVisible then
		loginDialog._passwordText:removeSelf()
	end
end

return loginDialog