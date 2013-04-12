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

local coronaRegisterDialog = {}

local widget = require "widget_orig"

coronaRegisterDialog._delegate = nil

coronaRegisterDialog.show = function ( delegate )
	coronaRegisterDialog._delegate = delegate

	coronaRegisterDialog._usernameText = nil
	coronaRegisterDialog._passwordText = nil
	coronaRegisterDialog._emailText = nil
	coronaRegisterDialog._userName = nil
	coronaRegisterDialog._password = nil
	coronaRegisterDialog._email = nil
	coronaRegisterDialog._originalY = nil
	coronaRegisterDialog._newY = nil
	coronaRegisterDialog._movingDistance = nil

	delegate._currentSection = 12
	delegate.visible = true

	-- we read the display dimensions locally, since they change on orientation change
	local DW = display.contentWidth
	local DH = display.contentHeight

	display.remove( delegate._loginDisplayGroup )
	delegate._loginDisplayGroup = display.newGroup()
	delegate._loginDisplayGroup.x = 0
	
	if coronaRegisterDialog._delegate._bg.isVisible == false then
		coronaRegisterDialog._delegate._bg.isVisible = true
	end
	
	local popupFrame

	if delegate._cloudHelper.isOrientationPortrait() then

		popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING, 20, DW - ( delegate.conf.WINDOW_PADDING * 2 ), 220 , delegate.conf.CORNER_RADIUS )

	else

		popupFrame = display.newRoundedRect(delegate._loginDisplayGroup, delegate.conf.WINDOW_PADDING + 40, 20, DW - ( delegate.conf.WINDOW_PADDING * 2 ) - 80, 200 , delegate.conf.CORNER_RADIUS )

	end

	popupFrame:setReferencePoint(display.CenterReferencePoint)
	popupFrame.strokeWidth = 5
	popupFrame:setStrokeColor( 255, 255, 255, 255 )
	popupFrame:setFillColor( 0, 0, 0, 200 )

	-- draw the logo
	local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
	logoImage:setReferencePoint( display.CenterLeftReferencePoint )
	delegate._loginDisplayGroup:insert( logoImage )
	logoImage.x = delegate.conf.LOGO_PADDING[ 1 ] + 30; logoImage.y = delegate.conf.LOGO_PADDING[ 2 ]
	logoImage.xScale = delegate.conf.globalScale / 4; logoImage.yScale = delegate.conf.globalScale / 4
	logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
	logoImage.type = "image"
	if delegate._cloudHelper.isOrientationPortrait() then
		logoImage.x = logoImage.x - 40; logoImage.y = logoImage.y
	end


	local loginHeaderText = display.newText( "Register" , 125, 11, delegate.conf.BOLD_FONT, 20 )
	delegate._loginDisplayGroup:insert( loginHeaderText )
	loginHeaderText:setReferencePoint( display.CenterLeftReferencePoint )
	loginHeaderText.y = logoImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
	loginHeaderText:setTextColor( 237, 28, 36, 255 )
	if delegate._cloudHelper.isOrientationPortrait() then
		loginHeaderText.x = loginHeaderText.x - 40
	end

	local guestText = display.newText( "Username:" , 120, 11, delegate.conf.REGULAR_FONT, 16 )
	delegate._loginDisplayGroup:insert( guestText )
	guestText:setReferencePoint( display.CenterLeftReferencePoint )
	guestText.y = loginHeaderText.y + 25 + delegate.conf.TEXT_BASELINE_CORRECTION
	guestText:setTextColor( 255, 255, 255, 255 )
	if delegate._cloudHelper.isOrientationPortrait() then
		guestText.x = guestText.x - 85
		guestText.y = guestText.y + 10
	end

	local passText = display.newText( "Password:" , 125, 11, delegate.conf.REGULAR_FONT, 16 )
	delegate._loginDisplayGroup:insert( passText )
	passText:setReferencePoint( display.CenterLeftReferencePoint )
	passText.y = loginHeaderText.y + 60 + delegate.conf.TEXT_BASELINE_CORRECTION
	passText:setTextColor( 255, 255, 255, 255 )
	if delegate._cloudHelper.isOrientationPortrait() then
		passText.x = passText.x - 85
		passText.y = passText.y + 10
	end
	
	local emailText = display.newText( "Email:" , 152, 11, delegate.conf.REGULAR_FONT, 16 )
	delegate._loginDisplayGroup:insert( emailText )
	emailText:setReferencePoint( display.CenterLeftReferencePoint )
	emailText.y = loginHeaderText.y + 95 + delegate.conf.TEXT_BASELINE_CORRECTION
	emailText:setTextColor( 255, 255, 255, 255 )
	if delegate._cloudHelper.isOrientationPortrait() then
		emailText.x = emailText.x - 85
		emailText.y = emailText.y + 10
	end

	coronaRegisterDialog._originalY = delegate._loginDisplayGroup.y
	coronaRegisterDialog._newY = delegate._cloudHelper._originalY

	local function usernameHandler( event )
		local moveQuantity = 50
		coronaRegisterDialog._movingDistance = 50
		if ( "began" == event.phase ) then
		elseif ( "ended" == event.phase ) then
			coronaRegisterDialog._userName = coronaRegisterDialog._usernameText.text
			native.setKeyboardFocus( nil )
		elseif ( "submitted" == event.phase ) then
			coronaRegisterDialog._userName = coronaRegisterDialog._usernameText.text
			native.setKeyboardFocus( nil )
		end
	end

	local function backgroundHandlerRegister( event )
		if ( "ended" == event.phase ) then
			native.setKeyboardFocus( nil )
			coronaRegisterDialog._userName = coronaRegisterDialog._usernameText.text
			coronaRegisterDialog._password = coronaRegisterDialog._passwordText.text
			coronaRegisterDialog._email = coronaRegisterDialog._emailText.text
		end
	end

	local function passwordHandler( event )
		local moveQuantity = 100
		coronaRegisterDialog._movingDistance = 100
		if ( "began" == event.phase ) then
		elseif ( "ended" == event.phase ) then
			coronaRegisterDialog._password = coronaRegisterDialog._passwordText.text
			native.setKeyboardFocus( nil )
		elseif ( "submitted" == event.phase ) then
			coronaRegisterDialog._password = coronaRegisterDialog._passwordText.text
			native.setKeyboardFocus( nil )
		end
	end
	
	local function emailHandler( event )
		local moveQuantity = 130
		coronaRegisterDialog._movingDistance = 130
		if ( "began" == event.phase ) then
		elseif ( "ended" == event.phase ) then
			coronaRegisterDialog._email = coronaRegisterDialog._emailText.text
			native.setKeyboardFocus( nil )
		elseif ( "submitted" == event.phase ) then
			coronaRegisterDialog._email = coronaRegisterDialog._emailText.text
			native.setKeyboardFocus( nil )
		end
	end

	delegate._loginDisplayGroup:addEventListener("touch", backgroundHandlerRegister )
	delegate._bg:addEventListener("touch", backgroundHandlerRegister )

	coronaRegisterDialog._usernameText = native.newTextField( 200, 70, 180, 25 )
	coronaRegisterDialog._usernameText:addEventListener("userInput", usernameHandler)

	coronaRegisterDialog._passwordText = native.newTextField( 200, 105, 180, 25 )
	coronaRegisterDialog._passwordText.isSecure = true
	coronaRegisterDialog._passwordText:addEventListener("userInput", passwordHandler)

	coronaRegisterDialog._emailText = native.newTextField( 200, 140, 180, 25 )
	coronaRegisterDialog._emailText:addEventListener("userInput", emailHandler)

	if delegate._cloudHelper.isOrientationPortrait() then
		coronaRegisterDialog._usernameText.x = coronaRegisterDialog._usernameText.x - 85
		coronaRegisterDialog._usernameText.y = coronaRegisterDialog._usernameText.y + 10
	end

	if delegate._cloudHelper.isOrientationPortrait() then
		coronaRegisterDialog._passwordText.x = coronaRegisterDialog._passwordText.x - 85
		coronaRegisterDialog._passwordText.y = coronaRegisterDialog._passwordText.y + 10
	end
	
	if delegate._cloudHelper.isOrientationPortrait() then
		coronaRegisterDialog._emailText.x = coronaRegisterDialog._emailText.x - 85
		coronaRegisterDialog._emailText.y = coronaRegisterDialog._emailText.y + 10
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
	    onRelease = coronaRegisterDialog.close
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
									coronaRegisterDialog.authenticateUser()
								end
							end
						end
					end
				end
			end
		end

		return true 
	end

	local confirmButton = display.newText( "Register", popupFrame.x + popupFrame.width * 0.5 - 40, popupFrame.y + popupFrame.height * 0.5 - 40, delegate.conf.BOLD_FONT, 20)
	delegate._loginDisplayGroup:insert( confirmButton )
	confirmButton:setReferencePoint( display.CenterLeftReferencePoint )
	confirmButton.y = popupFrame.y + popupFrame.height * 0.5 - 33 + delegate.conf.TEXT_BASELINE_CORRECTION
	confirmButton.x = popupFrame.x + popupFrame.width * 0.5 - 90
	confirmButton:setTextColor( 255, 255, 255, 255 )
	confirmButton.type = "text"
	confirmButton.tag = 5000
	confirmButton:addEventListener( "touch", onObjectTouch )

end

coronaRegisterDialog.authenticateUser = function()
	coronaRegisterDialog._userName = coronaRegisterDialog._usernameText.text
	coronaRegisterDialog._password = coronaRegisterDialog._passwordText.text
	coronaRegisterDialog._email = coronaRegisterDialog._emailText.text
	if not coronaRegisterDialog._userName or coronaRegisterDialog._userName == "" then
		local alert = native.showAlert( "Corona Cloud", "Please enter your username.", { "OK" } )
	elseif not coronaRegisterDialog._password or coronaRegisterDialog._password == "" then
		local alert = native.showAlert( "Corona Cloud", "Please enter your password.", { "OK" } )
	elseif not coronaRegisterDialog._email or coronaRegisterDialog._email == "" then
		local alert = native.showAlert( "Corona Cloud", "Please enter your email.", { "OK" } )
	else
		
		local registerParams = {}
		registerParams.displayName = coronaRegisterDialog._userName
		registerParams.firstName = ""
		registerParams.lastName = ""
		registerParams.email = coronaRegisterDialog._email
		registerParams.password = coronaRegisterDialog._password
		
		coronaRegisterDialog._delegate._pass = coronaRegisterDialog._password
		coronaRegisterDialog._delegate._user = coronaRegisterDialog._email
		
		coronaRegisterDialog._delegate.cc.registerUser( registerParams )
	end
	
end

coronaRegisterDialog.hide = function()
	if coronaRegisterDialog._delegate then
		coronaRegisterDialog._delegate._currentSection = 0
		coronaRegisterDialog._delegate.visible = false
		if nil ~= coronaRegisterDialog._usernameText and coronaRegisterDialog._usernameText.isVisible then
			coronaRegisterDialog._usernameText:removeSelf()
		end
		if nil ~= coronaRegisterDialog._passwordText and coronaRegisterDialog._passwordText.isVisible then
			coronaRegisterDialog._passwordText:removeSelf()
		end
		if nil ~= coronaRegisterDialog._emailText and coronaRegisterDialog._emailText.isVisible then
			coronaRegisterDialog._emailText:removeSelf()
		end
		display.remove( coronaRegisterDialog._delegate._loginDisplayGroup )
		coronaRegisterDialog._delegate._bg.isVisible = false
	end
end

coronaRegisterDialog.close = function()
		coronaRegisterDialog._delegate._currentSection = 0
		coronaRegisterDialog._delegate.visible = false
		if nil ~= coronaRegisterDialog._usernameText and coronaRegisterDialog._usernameText.isVisible then
			coronaRegisterDialog._usernameText:removeSelf()
		end
		if nil ~= coronaRegisterDialog._passwordText and coronaRegisterDialog._passwordText.isVisible then
			coronaRegisterDialog._passwordText:removeSelf()
		end
		if nil ~= coronaRegisterDialog._emailText and coronaRegisterDialog._emailText.isVisible then
			coronaRegisterDialog._emailText:removeSelf()
		end
		display.remove( coronaRegisterDialog._delegate._loginDisplayGroup )
		coronaRegisterDialog._delegate.showWelcomeDialog()
end

coronaRegisterDialog.cleanTexts = function()
	if nil ~= coronaRegisterDialog._usernameText and coronaRegisterDialog._usernameText.isVisible then
		coronaRegisterDialog._usernameText:removeSelf()
	end
	if nil ~= coronaRegisterDialog._passwordText and coronaRegisterDialog._passwordText.isVisible then
		coronaRegisterDialog._passwordText:removeSelf()
	end
	if nil ~= coronaRegisterDialog._emailText and coronaRegisterDialog._emailText.isVisible then
		coronaRegisterDialog._emailText:removeSelf()
	end
end

return coronaRegisterDialog