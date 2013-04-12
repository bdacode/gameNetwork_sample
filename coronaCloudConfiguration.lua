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

local coronaCloudConfiguration = {}

-- 
-- Variable and constant definitions
--

-- the asset loading suffix
coronaCloudConfiguration.assetSuffix = "1"
coronaCloudConfiguration.fileSuffix = ""
coronaCloudConfiguration.globalScale = 1

-- for most devices with scaling values between 0.6 and 0.25, we're talking about a retina device, non-tablet
if display.contentScaleX <= 0.6 and display.contentScaleX > 0.25 then
	coronaCloudConfiguration.assetSuffix = "2"
	coronaCloudConfiguration.fileSuffix = "@2x"
	coronaCloudConfiguration.globalScale = 0.5
-- and if we have a retina tablet
elseif display.contentScaleX <= 0.25 then
	coronaCloudConfiguration.assetSuffix = "4"
	coronaCloudConfiguration.fileSuffix = "@4x"
	coronaCloudConfiguration.globalScale = 0.25	
end

coronaCloudConfiguration.cloudAssets = {
	"cloud_imagesheet_1x.png",
	"cloud_imagesheet_2x.png",
	"cloud_imagesheet_4x.png",
	"mask-320x366.png",
	"mask-portrait.png",
}

for i = 1, #coronaCloudConfiguration.cloudAssets do
	local asset = coronaCloudConfiguration.cloudAssets[ i ]
	local fileExists = ( nil ~= system.pathForFile( "cloud_assets/" .. asset ) )
	-- if the file does not exist
	if fileExists ~= true then
		error("ERROR: one or more required files do not exist in the cloud_assets directory.")
	end
end

-- image sheets / theme
coronaCloudConfiguration.theme = "cloud_assets.cloud_imagesheet" -- was cloud_imagesheet
coronaCloudConfiguration.sheetInfo = require( coronaCloudConfiguration.theme .. "_" .. coronaCloudConfiguration.assetSuffix .. "x" )
local fileName = "cloud_assets/cloud_imagesheet" .. "_" ..coronaCloudConfiguration.assetSuffix.. "x.png"
coronaCloudConfiguration.cloudSheet = graphics.newImageSheet( "cloud_assets/cloud_imagesheet" .. "_" ..coronaCloudConfiguration.assetSuffix.. "x.png", coronaCloudConfiguration.sheetInfo:getSheet() )

-- the set of enabled dashboard features

coronaCloudConfiguration.enabledFeatures = {
	{ description = "Achievements", internal = "achievements", icon = "dash_achievements" .. coronaCloudConfiguration.fileSuffix, tag = 1000 },
--	{ description ="Messages", internal = "messages", icon = "dash_messages" .. coronaCloudConfiguration.fileSuffix, tag = 1002 },
	{ description ="Leaderboards", internal = "leaderboards", icon = "dash_leaderboards" .. coronaCloudConfiguration.fileSuffix, tag = 1003 },
	{ description ="Friends", internal = "friends", icon = "dash_friends" .. coronaCloudConfiguration.fileSuffix, tag = 1001 },
--	{ description ="Notifications", internal = "notifications", icon = "dash_notifications" .. coronaCloudConfiguration.fileSuffix, tag = 1004 },
--	{ description ="Social Connect", internal = "social", icon = "dash_social" .. coronaCloudConfiguration.fileSuffix, tag = 1005 },
	{ description ="News", internal = "news", icon = "dash_news" .. coronaCloudConfiguration.fileSuffix, tag = 1006 }
}



-- constants for tracking what's being displayed
coronaCloudConfiguration.S_DASHBOARD = 1
coronaCloudConfiguration.S_ACHIEVEMENTS = 2
coronaCloudConfiguration.S_FRIENDS = 3
coronaCloudConfiguration.S_MESSAGES = 4
coronaCloudConfiguration.S_LEADERBOARDS = 5
coronaCloudConfiguration.S_LEADERBOARD_DETAILS = 6
coronaCloudConfiguration.S_NOTIFICATIONS = 7
coronaCloudConfiguration.S_SOCIAL = 8
coronaCloudConfiguration.S_NEWS = 9
coronaCloudConfiguration.S_WELCOME = 10
coronaCloudConfiguration.S_LOGIN = 11
coronaCloudConfiguration.S_REGISTER = 12
coronaCloudConfiguration.S_UNLOCK_ACHIEVEMENT = 13
coronaCloudConfiguration.S_POST_HIGHSCORE = 14

-- the set of enabled account features

coronaCloudConfiguration.accountEnabledFeatures = {
	{ description = "Achievements", internal = "achievements", icon = "dash_achievements" .. coronaCloudConfiguration.fileSuffix, tag = 1000 },
	{ description ="Friends", internal = "friends", icon = "dash_friends" .. coronaCloudConfiguration.fileSuffix, tag = 1001 },
--	{ description ="Messages", internal = "messages", icon = "dash_messages" .. coronaCloudConfiguration.fileSuffix, tag = 1002 },
	{ description ="Leaderboards", internal = "leaderboards", icon = "dash_leaderboards" .. coronaCloudConfiguration.fileSuffix, tag = 1003 },
--	{ description ="Notifications", internal = "notifications", icon = "dash_notifications" .. coronaCloudConfiguration.fileSuffix, tag = 1004 },
--	{ description ="Social Connect", internal = "social", icon = "dash_social" .. coronaCloudConfiguration.fileSuffix, tag = 1005 },
	{ description ="News", internal = "news", icon = "dash_news" .. coronaCloudConfiguration.fileSuffix, tag = 1006 }
}

coronaCloudConfiguration.interfaceImages = {
	{ internal = "logo", icon = "corona_logo" .. coronaCloudConfiguration.fileSuffix, tag = 100 },
	{ internal = "closebutton", icon = "button_close" .. coronaCloudConfiguration.fileSuffix, tag = 200 },
	{ internal = "scrollbg", icon = "scrollbar_bg" .. coronaCloudConfiguration.fileSuffix, tag = 300 },
	{ internal = "scrollbgfill", icon = "scrollbar_pat" .. coronaCloudConfiguration.fileSuffix, tag = 400 },
	{ internal = "achievements", icon = "dash_achievements" .. coronaCloudConfiguration.fileSuffix, tag = 500 },
	{ internal = "leaderboards", icon = "dash_leaderboards" .. coronaCloudConfiguration.fileSuffix, tag = 600 },
	{ internal = "deletebutton", icon = "button_delete" .. coronaCloudConfiguration.fileSuffix, tag = 700 },
	{ internal = "friends", icon = "dash_friends" .. coronaCloudConfiguration.fileSuffix, tag = 800 },
	{ internal = "deletebutton_over", icon = "button_delete_over" .. coronaCloudConfiguration.fileSuffix, tag = 900 },
	{ internal = "popup_cancel", icon = "popup_cancel" .. coronaCloudConfiguration.fileSuffix, tag = 1000 },
	{ internal = "popup_confirm", icon = "popup_confirm" .. coronaCloudConfiguration.fileSuffix, tag = 1100 },
	{ internal = "news", icon = "dash_news" .. coronaCloudConfiguration.fileSuffix, tag = 1200 },
}

coronaCloudConfiguration.profileEnabledFeatures = {
--	{ description ="Messages", internal = "messages", icon = "dash_messages_over" .. coronaCloudConfiguration.fileSuffix, tag = 2001 },
	{ description ="Friends", internal = "friends", icon = "dash_friends_over" .. coronaCloudConfiguration.fileSuffix, tag = 2002 },
	{ description ="News", internal = "news", icon = "dash_news_over" .. coronaCloudConfiguration.fileSuffix, tag = 2003 },
--	{ description ="Notifications", internal = "notifications", icon = "dash_notifications_over" .. coronaCloudConfiguration.fileSuffix, tag = 2004 }
}

-- other features

-- transition time
coronaCloudConfiguration.TRANSITION_TIME = 400


-- the display constants we're gonna use.
coronaCloudConfiguration.DW = display.contentWidth
coronaCloudConfiguration.DH = display.contentHeight

-- graphics configuration variables

-- padding for all the windows
coronaCloudConfiguration.WINDOW_PADDING = 20
-- corner radius for the screens
coronaCloudConfiguration.CORNER_RADIUS = 10
-- underlapping corners
coronaCloudConfiguration.CORNER_UNDERLAP = 21
-- separator for texts
coronaCloudConfiguration.SEPARATOR_HEIGHT = 15
-- left padding of the objects
coronaCloudConfiguration.PADDING_LEFT = 26
-- height of the black margin on all the ui subviews
coronaCloudConfiguration.STATUSBAR_HEIGHT = 130
-- height of the gray navigation bar on all the ui subviews
coronaCloudConfiguration.NAVBAR_HEIGHT = 43
-- logo padding
coronaCloudConfiguration.LOGO_PADDING = { 45, 53 }

-- the main font used, with Android-conditional naming
coronaCloudConfiguration.MAIN_FONT = "HelveticaNeue-Medium"
if buildPlatform == "Android" then
	coronaCloudConfiguration.MAIN_FONT = native.systemFont
end

coronaCloudConfiguration.BOLD_FONT = "HelveticaNeue-Bold"
if buildPlatform == "Android" then
	coronaCloudConfiguration.BOLD_FONT = native.systemFontBold
end

coronaCloudConfiguration.REGULAR_FONT = "HelveticaNeue"
if buildPlatform == "Android" then
	coronaCloudConfiguration.REGULAR_FONT = native.systemFont
end

coronaCloudConfiguration.BOLDC_FONT = "HelveticaNeue-CondensedBold"
if buildPlatform == "Android" then
	coronaCloudConfiguration.BOLDC_FONT = native.systemFontBold
end

coronaCloudConfiguration.COND_FONT = "HelveticaNeue-CondensedBlack"
if buildPlatform == "Android" then
	coronaCloudConfiguration.COND_FONT = native.systemFont
end

-- text baseline correction for different platforms
coronaCloudConfiguration.TEXT_BASELINE_CORRECTION = 0
if buildPlatform == "Android" then
	coronaCloudConfiguration.TEXT_BASELINE_CORRECTION = -2
end

-- colors

-- the dark grey in the designs is the base color
coronaCloudConfiguration.BASE_COLOR = { 48, 48, 48, 255 }

-- the slightly lighter grey in the designs is the sub color
coronaCloudConfiguration.SUB_COLOR = { 38, 38, 38, 255 }

-- the border color
coronaCloudConfiguration.BORDER_COLOR = { 153, 153, 153, 255 }

-- the title text color
coronaCloudConfiguration.TITLE_COLOR = { 204, 204, 204, 255 }

-- the title over state text color
coronaCloudConfiguration.TITLE_OCOLOR = { 244, 126, 32, 255 }

-- the status bar present on all subviews
coronaCloudConfiguration.STATUSBAR_COLOR = { 0, 0, 0, 255 }

-- the navigation bar on all the ui subviews
coronaCloudConfiguration.NAVBAR_COLOR = { 69, 69, 69, 255 }

-- the top separator color
coronaCloudConfiguration.TOPSEP_COLOR = { 102, 102, 102, 255 }

-- the navbar separator color
coronaCloudConfiguration.NAVSEP_COLOR = { 178, 178, 178, 255 }

-- user profile stroke color
coronaCloudConfiguration.PROFILE_STROKE_COLOR = { 189, 189, 189, 255 }

-- table text for achievements, etc.
coronaCloudConfiguration.TABLETEXT_COLOR = { 76, 76, 76, 255 }

-- table text for scores
coronaCloudConfiguration.TABLETEXTS_COLOR = { 125, 125, 125, 255 }

-- overlay background color
coronaCloudConfiguration.OVERLAY_COLOR = { 147, 147, 147, 200 }

-- different texts used throughout the views
coronaCloudConfiguration.NO_LEADERBOARDS_TEXT = "No leaderboards defined."
coronaCloudConfiguration.NO_ACHIEVEMENTS_TEXT = "No achievements defined."
coronaCloudConfiguration.NO_SCORES_TEXT = "No scores."
coronaCloudConfiguration.NO_FRIENDS_TEXT = "No friends found."
coronaCloudConfiguration.NO_NEWS_TEXT = "No news found."

return coronaCloudConfiguration