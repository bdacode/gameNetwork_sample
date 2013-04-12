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

local coronaUnlockAchievement = {}

-- delegate, used for hiding the view
coronaUnlockAchievement._delegate = nil

coronaUnlockAchievement.hide = function()
	coronaUnlockAchievement._delegate._currentSection = 0
	coronaUnlockAchievement._delegate.visible = false
	transition.to( coronaUnlockAchievement._delegate._unlockAchievementDisplayGroup, {time = 250, alpha = 0.0, onComplete = function() 
			display.remove( coronaUnlockAchievement._delegate._unlockAchievementDisplayGroup )
		 end } )
	
end

coronaUnlockAchievement._moveDown = function()
	transition.to( coronaUnlockAchievement._delegate._unlockAchievementDisplayGroup, {y = coronaUnlockAchievement._delegate._unlockAchievementDisplayGroup.y + 80 } )
	timer.performWithDelay( 3000, coronaUnlockAchievement.hide )
end

coronaUnlockAchievement.show = function( textString, scoreString, delegate )

coronaUnlockAchievement._delegate = delegate

if delegate._bg.isVisible == true then
	delegate._bg.isVisible = false
end

delegate._currentSection = 13

delegate.visible = true

-- we read the display dimensions locally, since they change on orientation change
local DW = display.contentWidth
local DH = display.contentHeight

display.remove( delegate._unlockAchievementDisplayGroup )
delegate._unlockAchievementDisplayGroup = display.newGroup()
delegate._unlockAchievementDisplayGroup.x = 0
delegate._unlockAchievementDisplayGroup.y =  - display.contentHeight * 0.5 - 60
--delegate._unlockAchievementDisplayGroup.y =  0

local popupFrame

if delegate._cloudHelper.isOrientationPortrait() then

	popupFrame = display.newRoundedRect(delegate._unlockAchievementDisplayGroup, delegate.conf.WINDOW_PADDING, display.contentHeight * 0.5 - 30, DW - ( delegate.conf.WINDOW_PADDING * 2 ), 60 , delegate.conf.CORNER_RADIUS )

else

	popupFrame = display.newRoundedRect(delegate._unlockAchievementDisplayGroup, delegate.conf.WINDOW_PADDING + 40, display.contentHeight * 0.5 - 30, DW - ( delegate.conf.WINDOW_PADDING * 2 ) - 80, 60 , delegate.conf.CORNER_RADIUS )
	
end

popupFrame:setReferencePoint(display.CenterReferencePoint)
popupFrame.strokeWidth = 2
popupFrame:setStrokeColor( 255, 255, 255, 255 )
popupFrame:setFillColor( 0, 0, 0, 200 )

-- draw the logo
local logoImage = display.newImage( delegate.conf.cloudSheet ,delegate.conf.sheetInfo:getFrameIndex( delegate.conf.interfaceImages[ 1 ].icon ))
logoImage:setReferencePoint( display.CenterLeftReferencePoint )
delegate._unlockAchievementDisplayGroup:insert( logoImage )
logoImage.x = popupFrame.x + popupFrame.contentWidth * 0.5 - 80; logoImage.y = popupFrame.y + 5
logoImage.xScale = delegate.conf.globalScale / 5; logoImage.yScale = delegate.conf.globalScale / 5
logoImage.tag = delegate.conf.interfaceImages[ 1 ].tag
logoImage.type = "image"
if delegate._cloudHelper.isOrientationPortrait() then
	logoImage.x = logoImage.x
end

local loginHeaderText = display.newText( textString , 80, 11, delegate.conf.BOLD_FONT, 16 )
delegate._unlockAchievementDisplayGroup:insert( loginHeaderText )
loginHeaderText:setReferencePoint( display.CenterLeftReferencePoint )
loginHeaderText.y = logoImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
loginHeaderText:setTextColor( 255, 255, 255, 255 )

if delegate._cloudHelper.isOrientationPortrait() then
	loginHeaderText.x = loginHeaderText.x - 40
end

local scoreNumber = tonumber( scoreString )
local input = scoreNumber
local input2 = string.gsub(input, "(%d)(%d%d%d)$", "%1,%2", 1)
local found
while true do
    input2, found = string.gsub(input2, "(%d)(%d%d%d),", "%1,%2,", 1)
    if found == 0 then break end
end

local achievementText = display.newText( input2 , logoImage.x + 40, 11, delegate.conf.BOLDC_FONT, 16 )
delegate._unlockAchievementDisplayGroup:insert( achievementText )
achievementText:setReferencePoint( display.CenterLeftReferencePoint )
achievementText.y = logoImage.y + delegate.conf.TEXT_BASELINE_CORRECTION
achievementText.x = logoImage.x + 40
achievementText:setTextColor( unpack( delegate.conf.TITLE_OCOLOR ) )

coronaUnlockAchievement._moveDown()

end

return coronaUnlockAchievement