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

local welcomeDialog = {}

local widget = require "widget_orig"

-- delegate, used for hiding the view
welcomeDialog._delegate = nil

welcomeDialog.show = function( delegate )

welcomeDialog._delegate = delegate

delegate._currentSection = 10
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

	popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING, display.contentHeight * 0.5 - 150, DW - ( delegate.conf.WINDOW_PADDING * 2 ), 300 , delegate.conf.CORNER_RADIUS )

else

	popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING + 40, display.contentHeight * 0.5 - 100, DW - ( delegate.conf.WINDOW_PADDING * 2 ) - 80, 200 , delegate.conf.CORNER_RADIUS )
	
end

popupFrame:setReferencePoint(display.CenterReferencePoint)
popupFrame.strokeWidth = 5
popupFrame:setStrokeColor( 255, 255, 255, 255 )
popupFrame:setFillColor( 0, 0, 0, 200 )

-- draw the logo
local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
logoImage:setReferencePoint( display.CenterLeftReferencePoint )
delegate._loginDisplayGroup:insert( logoImage )
logoImage.x = delegate.conf.LOGO_PADDING[ 1 ] + 35; logoImage.y = delegate.conf.LOGO_PADDING[ 2 ] + 50
logoImage.xScale = delegate.conf.globalScale / 4; logoImage.yScale = delegate.conf.globalScale / 4
logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
logoImage.type = "image"
if delegate._cloudHelper.isOrientationPortrait() then
	logoImage.x = logoImage.x - 40; logoImage.y = logoImage.y + 20
end

local loginHeaderText = display.newText( "Welcome!" , 130, 11, delegate.conf.BOLD_FONT, 20 )
delegate._loginDisplayGroup:insert( loginHeaderText )
loginHeaderText:setReferencePoint( display.CenterLeftReferencePoint )
loginHeaderText.y = logoImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
loginHeaderText:setTextColor( 237, 28, 36, 255 )

if delegate._cloudHelper.isOrientationPortrait() then
	loginHeaderText.x = loginHeaderText.x - 40
end

local guestText = display.newText( "New to Corona Cloud?" , 130, 11, delegate.conf.REGULAR_FONT, 16 )
delegate._loginDisplayGroup:insert( guestText )
guestText:setReferencePoint( display.CenterLeftReferencePoint )
guestText.y = loginHeaderText.y + 30 + delegate.conf.TEXT_BASELINE_CORRECTION
guestText:setTextColor( 255, 255, 255, 255 )

if delegate._cloudHelper.isOrientationPortrait() then
	guestText.x = guestText.x - 40; guestText.y = guestText.y + 20
end

local registerButton = widget.newButton{
    id = "registerAccount",
    left = 128,
    top = 150,
    width = 90, height = 25,
	fontSize = 17,
	font = delegate.conf.BOLD_FONT,
	labelColor = { default={ 244, 126, 32, 255 }, over={ 135, 70, 18, 255 } },
    defaultColor = { 0, 0, 0, 0 },
	overColor = { 0, 0, 0, 0 },
	strokeColor = { 0, 0, 0, 0 },
	label = "Register a new account",
    onRelease = delegate.showRegisterDialog
}
delegate._loginDisplayGroup:insert( registerButton )

if delegate._cloudHelper.isOrientationPortrait() then
	registerButton.x = registerButton.x - 40; registerButton.y = registerButton.y + 45
end

local loginText = display.newText( "Already registered?" , 130, 11, delegate.conf.REGULAR_FONT, 16 )
delegate._loginDisplayGroup:insert( loginText )
loginText:setReferencePoint( display.CenterLeftReferencePoint )
loginText.y = registerButton.y + 30 + delegate.conf.TEXT_BASELINE_CORRECTION
loginText:setTextColor( 255, 255, 255, 255 )

if delegate._cloudHelper.isOrientationPortrait() then
	loginText.x = loginText.x - 40; loginText.y = loginText.y + 25
end

local loginButton = widget.newButton{
    id = "loginAccount",
    left = 104,
    top = 207,
    width = 90, height = 25,
	fontSize = 17,
	font = delegate.conf.BOLD_FONT,
	labelColor = { default={ 244, 126, 32, 255 }, over={ 135, 70, 18, 255 } },
    defaultColor = { 0, 0, 0, 0 },
	overColor = { 0, 0, 0, 0 },
	strokeColor = { 0, 0, 0, 0 },
	label = "Login",
    onRelease = delegate.showLoginDialog
}
delegate._loginDisplayGroup:insert( loginButton )

if delegate._cloudHelper.isOrientationPortrait() then
	loginButton.x = loginButton.x - 40; loginButton.y = loginButton.y + 75
end

if delegate._usesFacebook then

local loginFButton = widget.newButton{
    id = "loginFAccount",
    left = 200,
    top = 207,
    width = 90, height = 25,
	fontSize = 17,
	font = delegate.conf.BOLD_FONT,
	labelColor = { default={ 244, 126, 32, 255 }, over={ 135, 70, 18, 255 } },
    defaultColor = { 0, 0, 0, 0 },
	overColor = { 0, 0, 0, 0 },
	strokeColor = { 0, 0, 0, 0 },
	label = "Login with Facebook",
    onRelease = delegate.facebookLogin
}
delegate._loginDisplayGroup:insert( loginFButton )

if delegate._cloudHelper.isOrientationPortrait() then
	loginFButton.x = loginFButton.x - 112; loginFButton.y = loginFButton.y + 105
end

end

-- the close button
local deleteFriend = widget.newButton{
    id = "deleteFriend",
    left = popupFrame.x + popupFrame.width * 0.5 - 40,
    top = 70,
    width = 28, height = 28,
    sheet = delegate.conf.cloudSheet,
	defaultIndex = delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 10 ].icon ),
	overIndex = delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 10 ].icon ),
    onRelease = welcomeDialog.hide
}
delegate._loginDisplayGroup:insert( deleteFriend )

if delegate._cloudHelper.isOrientationPortrait() then
	deleteFriend.y = deleteFriend.y + 32
end

end

welcomeDialog.hide = function()
	welcomeDialog._delegate._currentSection = 0
	welcomeDialog._delegate.visible = false
	display.remove( welcomeDialog._delegate._loginDisplayGroup )
	welcomeDialog._delegate._bg.isVisible = false
end

return welcomeDialog