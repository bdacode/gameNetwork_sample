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

local instance = {}

-- include the cloud controller
instance.cc = require ( "coronaCloudController" )

-- include the bootstrap configuration file
instance.conf = require ( "coronaCloudConfiguration" )

-- json
local json = require("json")

-- facebook
local facebook = require("facebook")

-- include the cloudHelper
instance._cloudHelper = require ( "coronaCloudHelper" )

-- include the widget library
local widget = require "widget_orig"

-- include the corona subviews
local _dashboard = require ( "coronaCloudDashboard" )
local _leaderboards = require ( "coronaCloudLeaderboards" )
local _leaderboardDetails = require ( "coronaCloudLeaderboardDetails" )
local _achievements = require ( "coronaCloudAchievements" )
local _friends = require ( "coronaCloudFriends" )
local _welcome = require ( "coronaWelcomeDialog" )
local _login = require ( "coronaLoginDialog" )
local _register = require ( "coronaRegisterDialog" )
local _unlockAchievement = require ( "coronaUnlockAchievement" )
local _submitHighscore = require ( "coronaSubmitHighscore" )
local _news = require ( "coronaNews" )

-- display mode
instance._displayMode = "landscape"

-- theme
instance._theme = nil

-- type of user accounts: automatic, or created by the enduser
instance._autoCreateAccounts = false

-- facebook related variables
instance._usesFacebook = false
instance._facebookAppId = nil
instance._facebookToken = nil
instance._facebookId = nil

-- requested section when not logged in
instance._requestedSection = ""

-- logged in tracker
instance._userLoggedIn = false

-- class variables
-- the grid division for drawing the gray / light gray bars
instance._gridDivision = 0

-- supported orientations
instance._orientations = { "portrait", "portraitUpsideDown", "landscapeLeft", "landscapeRight" }

-- bg
instance._bg = nil

-- temporary variable for the user password
instance._pass = nil
instance._user = nil

-- achievement table to be passed in
instance._achievementTable = nil

-- highscore table to be passed in
instance._highscoreTable = nil

-- counter for the cache requests
instance._cacheCounter = 0
instance._didReload = 0

-- the activity logo
instance._activityIndicator = nil
instance._activityTransition = nil

-- the current displayed section: 1- Dashboard, 
instance._currentSection = 0

-- flag for tracking if the UI has been inited
instance._didInitInterface = false

-- internal datacaches
instance._cache = {}
-- user profile
instance._cache._userCache = {}
-- achievements
instance._cache._achievementsCache = {}
-- game infos
instance._cache._infoCache = {}
-- news
instance._cache._newsCache = {}
-- friends
instance._cache._friendsCache = {}
-- friends details
instance._cache._friendDetailsCache = {}
-- leaderboards
instance._cache._leaderboardsCache = {}
-- leaderboard details
instance._cache._leaderboardDetailsCache = {}

-- container display group
instance._displayGroup = display.newGroup()

-- active display group
instance._activeDisplayGroup = nil

-- public, instance.visible. Conditional calls from the coronaCloudController are made only if the instance is visible.
instance.visible = false

-- current leaderboard (variable used only in the view leaderboard details view)
instance._currentLeaderboard = nil

-- the localized cloud variables

-- the cloud listeners
local authListener = function( event )
	if event.type == "facebookLoggedIn" then
		instance.cc.getProfile()
		instance.leaderboards.getAll()
		instance.cc.getInfo()
		instance.friends.getAll()
		instance.news.getAll()
		instance.leaderboards.getAll()
		instance.achievements.getAll()
		instance.facebookCallback()
		
	elseif event.type == "loggedIn" then
			if event.error then
				instance.showError( event.error ) 
			else
				instance.cc.getProfile()
				instance.leaderboards.getAll()
				instance.cc.getInfo()
				instance.friends.getAll()
				instance.news.getAll()
				instance.leaderboards.getAll()
				instance.achievements.getAll()
		
				if nil ~= instance._pass then
					instance.endAuthenticateUser( instance._pass )
				end
				
				instance.logUserIn()
			
			end
			
	elseif event.type == "getProfile" then
		instance.updateCache( "user", json.decode( event.response ) )
		
	elseif event.type == "getUserProfile" then
		instance.updateCache( "friendDetails", json.decode( event.response ) )
	
	elseif event.type == "getInfo" then
		instance.updateCache("info", json.decode( event.response ) )
	
	elseif event.type == "registerUser" then
		if nil ~= instance._pass and nil ~= instance._user then
			instance.authenticateUser( instance._user, instance._pass )
		end
	
	end
	
end

local newsListener = function( event )
	if event.type == "getAll" then
		instance.updateCache( "news", json.decode( event.response) )
	end
end

local achievementsListener = function( event )
	if event.type == "getAll" then
		instance.updateCache( "achievements", json.decode( event.response) )
	end
end

local friendsListener = function( event )
	if event.type == "getAll" then
		instance.updateCache( "friends", json.decode( event.response) )
	end
end

local leaderboardsListener = function( event )
	if event.type == "getAll" then
		instance.updateCache( "leaderboards", json.decode( event.response) )
	elseif event.type == "getScores" then
		instance.updateCache( "leaderboardDetails", json.decode( event.response ) )
	end
end

instance.achievements = instance.cc.achievements
instance.achievements.setListener( achievementsListener )

instance.friends = instance.cc.friends
instance.friends.setListener( friendsListener )

instance.news = instance.cc.news
instance.news.setListener( newsListener )

instance.leaderboards = instance.cc.leaderboards
instance.leaderboards.setListener( leaderboardsListener )

-- facebook listener
local function FBListener( event )
    if ( "session" == event.type ) then
        -- upon successful login, request list of friends of the signed in user
        if ( "login" == event.phase ) then
			facebook.request( "me" )
			instance._facebookToken = event.token
			
		end
	elseif ( "request" == event.type ) then
	        local response = json.decode( event.response )
			if nil ~= response.id then
			instance._facebookId = response.id
			instance._cache._userCache.username = response.username
			instance._cloudHelper._saveCloudDataToFile( instance._cache )
			end
			instance.facebookLogin()
    elseif ( "dialog" == event.type ) then

    end
end

-- runtime event listener method
instance._onOrientationChange = function( event )
	
	local DW = display.contentWidth
	local DH = display.contentHeight
	local math_abs = math.abs
	local ox, oy = math_abs(display.screenOriginX), math_abs(display.screenOriginY)
	local screenWidth = DW - (display.screenOriginX*2)
	local screenRealWidth = screenWidth / display.contentScaleX

	local screenHeight = DH - (display.screenOriginY*2)
	local screenRealHeight = screenHeight / display.contentScaleY
	
	local isOrientationSupported = false
	for i=1, #instance._orientations do
		if event.type == instance._orientations[ i ] then
			isOrientationSupported = true
		end
	end
	
	if isOrientationSupported then
	
	if instance._currentSection == instance.conf.S_DASHBOARD then
		instance.showDashboard()
	elseif instance._currentSection == instance.conf.S_ACHIEVEMENTS then
		instance.showAchievements()
	elseif instance._currentSection == instance.conf.S_FRIENDS then
		instance.showFriends( {} )
	elseif instance._currentSection == instance.conf.S_MESSAGES then
		--
	elseif instance._currentSection == instance.conf.S_LEADERBOARDS then
		instance.showLeaderboards( {} )
	elseif instance._currentSection == instance.conf.S_LEADERBOARD_DETAILS then
		instance.showLeaderboardDetails( instance._currentLeaderboard )
	elseif instance._currentSection == instance.conf.S_NOTIFICATIONS then
		--
	elseif instance._currentSection == instance.conf.S_SOCIAL then
		--
	elseif instance._currentSection == instance.conf.S_NEWS then
		instance.showNews()
	elseif instance._currentSection == instance.conf.S_WELCOME then
		instance.showWelcomeDialog()
	elseif instance._currentSection == instance.conf.S_LOGIN then
		instance.showLoginDialog()
	elseif instance._currentSection == instance.conf.S_REGISTER then
		_register.cleanTexts()
		_register.show( instance )
	elseif instance._currentSection == instance.conf.S_UNLOCK_ACHIEVEMENT then
		_unlockAchievement.show( instance._achievementTable[ 1 ], instance._achievementTable[ 2 ], instance )
	elseif instance._currentSection == instance.conf.S_POST_HIGHSCORE then
		_submitHighscore.show( instance._highscoreTable[ 1 ], instance )
	end
	
	if event.type == "portrait" or event.type == "portraitUpsideDown" then
		instance._activityIndicator.x = instance._activityIndicator.x + 40
		instance._activityIndicator.y = instance._activityIndicator.y - 40
		instance._activityIndicator.xScale = instance.conf.globalScale / 6
		instance._activityIndicator.yScale = instance.conf.globalScale / 6
		instance._activityIndicator.alpha = 0.0
		instance._bg.x = - ox + screenRealWidth * 0.5
	else
		instance._activityIndicator.x = DW - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.y = DH - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.xScale = instance.conf.globalScale / 6
		instance._activityIndicator.yScale = instance.conf.globalScale / 6
		instance._activityIndicator.alpha = 0.0
		instance._bg.x = - ox + screenRealHeight * 0.5
	end


	
	end -- isOrientationSupported
	
end

instance.showFriendDeletePopup = function (event )

	-- we read the display dimensions locally, since they change on orientation change
	local DW = display.contentWidth
	local DH = display.contentHeight

	local overlayBg = display.newRect( 0,0, display.contentWidth, display.contentHeight )
	overlayBg:setFillColor( 255, 255, 255, 1 )

	display.remove( instance._friendsDeleteDisplayGroup )
	instance._friendsDeleteDisplayGroup = display.newGroup()
	instance._friendsDeleteDisplayGroup.x = 0
	instance._friendsDeleteDisplayGroup:insert( overlayBg )
	
	local popupFrame = display.newRoundedRect(instance._friendsDeleteDisplayGroup, instance.conf.WINDOW_PADDING + 40, display.contentHeight * 0.5 - 50, DW - ( instance.conf.WINDOW_PADDING * 2 ) - 80, 100 , instance.conf.CORNER_RADIUS )
	popupFrame:setReferencePoint(display.CenterReferencePoint)
	popupFrame.strokeWidth = 5
	popupFrame:setStrokeColor( 255, 255, 255, 255 )
	popupFrame:setFillColor( 0, 0, 0, 200 )
	
	-- prevent subsequent touches
	overlayBg:addEventListener("touch", function() return true end)
	overlayBg:addEventListener("tap", function() return true end)

end

-- interface initializer method
instance.initInterface = function( displayMode )
	
	local DW = display.contentWidth
	local DH = display.contentHeight
	local math_abs = math.abs
	local ox, oy = math_abs(display.screenOriginX), math_abs(display.screenOriginY)
	
	instance._displayMode = displayMode or "landscape"
	Runtime:addEventListener( "orientation", instance._onOrientationChange )
	
	instance._activityIndicator = display.newImage( instance.conf.cloudSheet ,instance.conf.sheetInfo:getFrameIndex( instance.conf.interfaceImages[ 1 ].icon ))
	instance._activityIndicator:setReferencePoint( display.CenterReferencePoint )
	
	if instance._cloudHelper.isOrientationPortrait() then
		instance._activityIndicator.x = DW - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.y = DH - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.xScale = instance.conf.globalScale / 6
		instance._activityIndicator.yScale = instance.conf.globalScale / 6
		instance._activityIndicator.alpha = 0.0
	else
		instance._activityIndicator.x = DW - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.y = DH - ( instance.conf.WINDOW_PADDING * 2 ) - 50
		instance._activityIndicator.xScale = instance.conf.globalScale / 6
		instance._activityIndicator.yScale = instance.conf.globalScale / 6
		instance._activityIndicator.alpha = 0.0
	end
	
	if instance._bg == nil then
	-- redraw the bg
	local screenWidth = display.contentWidth - (display.screenOriginX*2)
	local screenRealWidth = screenWidth / display.contentScaleX

	local screenHeight = display.contentHeight - (display.screenOriginY*2)
	local screenRealHeight = screenHeight / display.contentScaleY

	instance._bg = display.newRect( - ox , - oy, screenRealWidth, screenRealHeight )
	instance._bg:setFillColor( unpack( instance.conf.OVERLAY_COLOR ) )
	instance._displayGroup:insert( instance._bg )
	instance._bg.isVisible = false

	-- prevent subsequent touches
	instance._bg:addEventListener("touch", function() return true end)
	instance._bg:addEventListener("tap", function() return true end)
	
	end
	

end

instance._startActivity = function()
	instance._activityIndicator:toFront()
	instance._activityIndicator.alpha = 1.0
	instance._activityTransition = transition.to( instance._activityIndicator, { time = 200, xScale = 0.01, onComplete = function() 
			instance._startActivityReverse()
		end } )
end

instance._startActivityReverse = function()
	instance._activityTransition = transition.to( instance._activityIndicator, { time = 200, xScale = instance.conf.globalScale / 6, onComplete = function() 
			instance._startActivity()
		end } )
end

instance._stopActivity = function()
	if instance._activityTransition then
		transition.cancel( instance._activityTransition )
		instance._activityTransition = nil
	end
	instance._activityIndicator.xScale = instance.conf.globalScale / 6
	instance._activityIndicator.alpha = 0.0
end

-- initializer method
instance.init = function( ... )
	
	local params = arg[ 2 ] or {}
	
	local accessKey = params.accessKey or nil
	if nil == accessKey or "" == accessKey then
		error( "ERROR: You must supply a accessKey obtained from http://api.coronalabs.com" )
	end
	
	local secretKey = params.secretKey or nil
	if nil == secretKey or "" == secretKey then
		error( "ERROR: You must supply a secretKey obtained from http://api.coronalabs.com" )
	end
	
	if accessKey and secretKey then
		instance.cc.init( accessKey, secretKey, authListener )
	end

	if nil ~= params.supportedOrientations and #params.supportedOrientations > 0 then
		instance._orientations = params.supportedOrientations
	end
	
	if nil ~= params.facebookApplicationId and "" ~= params.facebookApplicationId then
		instance._usesFacebook = true
		instance._facebookAppId = params.facebookApplicationId
	end
	
	instance.initInterface()
end

-- finalizer method
instance._destroy = function ()
	Runtime:deleteEventListener( "orientation", instance._onOrientationChange )
end

-- showWelcomeDialog
-- public, displays the welcome dialog if the user is not logged in
instance.showWelcomeDialog = function ()
	_welcome.show( instance )
	
end

instance.showRegisterDialog = function()
	_register.show( instance )
end

instance.showNews = function()
	_news.show( instance )
end

instance.showLoginDialog = function()

	_welcome.hide()
	_login.cleanTexts()
	_login.show( instance )
end

instance.facebookLogin = function()
	if instance._facebookAppId ~= nil and instance._facebookToken ~= nil and instance._facebookId ~=nil then
		-- user has both things, we can login
		
		local loginParams = {}
		loginParams.type = "facebook"
		loginParams.facebookId = instance._facebookId
		loginParams.accessToken = instance._facebookToken
		-- login to Facebook
		instance.cc.login( loginParams )
		
		instance._cache._timestampCache = instance._cloudHelper._b64enc( instance._facebookToken )
		instance._cache._loginMode = "f"
		instance._cache._sessionCache = instance._facebookId
		-- write the data to cache
		instance._cloudHelper._saveCloudDataToFile( instance._cache )

	elseif instance._facebookAppId ~=nil then
		-- user has to login first, so we do that
		facebook.login( instance._facebookAppId, FBListener, {"publish_stream", "email"} )
	end
end

instance.facebookCallback = function()
	if instance._requestedSection ~="" then
		if _welcome then
			_welcome.hide()
		end
		if _login then
			_login.hide()
		end
		instance.show( instance._requestedSection )
		instance._stopActivity()
	end
end

instance.getInfo = function()
	instance.cc.getInfo()
end

instance.authenticateUser = function( username, password )
	if _register then
		_register.hide()
	end
	--if _login then
	--	_login.hide()
	--end
	
	local loginParams = {}
	loginParams.type = "user"
	loginParams.email = username
	loginParams.password = password
	
	instance.cc.login( loginParams )
end

instance.endAuthenticateUser = function( password )
	instance._cache._timestampCache = instance._cloudHelper._b64enc(password)
	instance._cache._sessionCache = ""
	instance._cache._loginMode = "w"
	-- write the data to cache
	instance._cloudHelper._saveCloudDataToFile( instance._cache )
	instance._stopActivity()
end

instance.showError = function ( message )
	local alert = native.showAlert( "Corona Cloud", message, { "OK" } )
	instance._stopActivity()
end

instance.logUserIn = function()
	if instance._requestedSection ~="" then
		if _login then
			_login.hide()
		end
		if _welcome then
			_welcome.hide()
		end
		instance.show( instance._requestedSection )
		instance._stopActivity()
	end
end

-- showDashboard
-- public, displays the dashboard width instance as delegate for callbacks
instance.showDashboard = function()
	_dashboard.show( instance )
end

-- showAchievements
-- public, displays the achievements
instance.showAchievements = function( responseObject )
	instance._cache = instance._cloudHelper._loadCloudDataFromFile()
	if instance._cache and instance._cache._achievementsCache then
		responseObject = instance._cache._achievementsCache
	end
	
	_achievements.show( responseObject, instance )
end

-- showLeaderboards
-- public, displays the leaderboards
instance.showLeaderboards = function( responseObject )
	instance._cache = instance._cloudHelper._loadCloudDataFromFile()
	if instance._cache and instance._cache._leaderboardsCache then
		responseObject = instance._cache._leaderboardsCache
	end
	_leaderboards.show( responseObject, instance )
end

-- showLeaderboards
-- public, displays the leaderboards
instance.showLeaderboardDetails = function( leaderboardId, responseObject )
	_leaderboardDetails.show ( leaderboardId, responseObject, instance )
end

-- showFriends
-- public, displays the friend list
instance.showFriends = function( responseObject )
	_friends.show( responseObject, instance )
end

-------------------------------------------------
-- display methods
-------------------------------------------------

-- internal, used for credential verification

instance.show = function( view, arguments )
	local argList = arguments
	
	if "achievements" == view then
		local isLoggedIn = instance.cc.isLoggedIn
		if not isLoggedIn then
			-- check credentials
			local dataTable = instance._cloudHelper._loadCloudDataFromFile()
			-- logged in user 
			if nil ~= dataTable and nil ~= dataTable._timestampCache and nil~= dataTable._loginMode then
				if dataTable._loginMode == "f" then
				-- facebook logged in user	
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "facebook"
				loginParams.facebookId = dataTable._sessionCache
				loginParams.accessToken = instance._cloudHelper._b64dec(dataTable._timestampCache)
				instance.cc.login( loginParams )
				
				--instance.cc.loginFacebook( dataTable._sessionCache, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				elseif dataTable._loginMode == "w" then
				-- web logged in user
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "user"
				loginParams.email = dataTable._userCache.email
				loginParams.password = instance._cloudHelper._b64dec(dataTable._timestampCache)

				instance.cc.login( loginParams )
				
				--instance.cc.loginAPI(dataTable._userCache.email, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				end
			end
				instance._requestedSection = "achievements"
				instance.showWelcomeDialog()
		else
			instance.showAchievements()
		end
		
	elseif "dashboard" == view then
		local isLoggedIn = instance.cc.isLoggedIn
		if not isLoggedIn then
			-- check credentials
			local dataTable = instance._cloudHelper._loadCloudDataFromFile()
			-- logged in user 
			if nil ~= dataTable and nil ~= dataTable._timestampCache and nil~= dataTable._loginMode then
				if dataTable._loginMode == "f" then
				-- facebook logged in user	
				instance._startActivity()
				
				-- params.type has to be user, facebook or session
				-- for user, we read params.email and params.password
				-- for facebook, params.facebookId and params.accessToken
				-- for session, params.authToken
				
				local loginParams = {}
				loginParams.type = "facebook"
				loginParams.facebookId = dataTable._sessionCache
				loginParams.accessToken = instance._cloudHelper._b64dec(dataTable._timestampCache)
				instance.cc.login( loginParams )
				--instance.cc.loginFacebook( dataTable._sessionCache, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				elseif dataTable._loginMode == "w" then
				-- web logged in user
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "user"
				loginParams.email = dataTable._userCache.email
				loginParams.password = instance._cloudHelper._b64dec(dataTable._timestampCache)

				instance.cc.login( loginParams )
				
				--instance.cc.loginAPI(dataTable._userCache.email, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				end
			end
				instance._requestedSection = "dashboard"
				instance.showWelcomeDialog()
		else
			instance.showDashboard()
		end
		
		elseif "news" == view then
			local isLoggedIn = instance.cc.isLoggedIn
			if not isLoggedIn then
				-- check credentials
				local dataTable = instance._cloudHelper._loadCloudDataFromFile()
				-- logged in user 
				if nil ~= dataTable and nil ~= dataTable._timestampCache and nil~= dataTable._loginMode then
					if dataTable._loginMode == "f" then
					-- facebook logged in user	
					instance._startActivity()
					
					local loginParams = {}
					loginParams.type = "facebook"
					loginParams.facebookId = dataTable._sessionCache
					loginParams.accessToken = instance._cloudHelper._b64dec(dataTable._timestampCache)
					instance.cc.login( loginParams )
					
					--instance.cc.loginFacebook( dataTable._sessionCache, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
					elseif dataTable._loginMode == "w" then
					-- web logged in user
					instance._startActivity()
					
					local loginParams = {}
					loginParams.type = "user"
					loginParams.email = dataTable._userCache.email
					loginParams.password = instance._cloudHelper._b64dec(dataTable._timestampCache)

					instance.cc.login( loginParams )
					
					--instance.cc.loginAPI(dataTable._userCache.email, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
					end
				end
					instance._requestedSection = "news"
					instance.showWelcomeDialog()
			else
				instance.showNews()
			end
		
	elseif "friends" == view then
		local isLoggedIn = instance.cc.isLoggedIn
		if not isLoggedIn then
			
			-- check credentials
			local dataTable = instance._cloudHelper._loadCloudDataFromFile()
			-- logged in user 
			if nil ~= dataTable and nil ~= dataTable._timestampCache and nil~= dataTable._loginMode then
				if dataTable._loginMode == "f" then
				-- facebook logged in user	
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "facebook"
				loginParams.facebookId = dataTable._sessionCache
				loginParams.accessToken = instance._cloudHelper._b64dec(dataTable._timestampCache)
				instance.cc.login( loginParams )
				
				--instance.cc.loginFacebook( dataTable._sessionCache, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				elseif dataTable._loginMode == "w" then
				-- web logged in user
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "user"
				loginParams.email = dataTable._userCache.email
				loginParams.password = instance._cloudHelper._b64dec(dataTable._timestampCache)

				instance.cc.login( loginParams )
				
				--instance.cc.loginAPI(dataTable._userCache.email, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				end
			end
				instance._requestedSection = "friends"
				instance.showWelcomeDialog()

		else
			instance.showFriends()
		end
	elseif "leaderboards" == view then
		local isLoggedIn = instance.cc.isLoggedIn
		if not isLoggedIn then
			
			-- check credentials
			local dataTable = instance._cloudHelper._loadCloudDataFromFile()
			-- logged in user 
			if nil ~= dataTable and nil ~= dataTable._timestampCache and nil~= dataTable._loginMode then
				if dataTable._loginMode == "f" then
				-- facebook logged in user	
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "facebook"
				loginParams.facebookId = dataTable._sessionCache
				loginParams.accessToken = instance._cloudHelper._b64dec(dataTable._timestampCache)
				instance.cc.login( loginParams )
				
				--instance.cc.loginFacebook( dataTable._sessionCache, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				elseif dataTable._loginMode == "w" then
				-- web logged in user
				instance._startActivity()
				
				local loginParams = {}
				loginParams.type = "user"
				loginParams.email = dataTable._userCache.email
				loginParams.password = instance._cloudHelper._b64dec(dataTable._timestampCache)

				instance.cc.login( loginParams )
				
				--instance.cc.loginAPI(dataTable._userCache.email, instance._cloudHelper._b64dec(dataTable._timestampCache), instance )
				end
			end
				instance._requestedSection = "leaderboards"
				instance.showWelcomeDialog()

		else
			instance.showLeaderboards()
		end
	elseif "unlock_achievement" == view then
		instance._achievementTable = { argList[1], argList[2] }
		_unlockAchievement.show( instance._achievementTable[ 1 ], instance._achievementTable[ 2 ], instance )
		instance._bg.isVisible = false
	elseif "post_highscore" == view then
		instance._highscoreTable = { argList[1] }
		_submitHighscore.show( instance._highscoreTable[ 1 ], instance )
		instance._bg.isVisible = false
	end
end

-- setTheme
instance.setTheme = function( theme )
	instance._theme = theme
	instance.conf.theme = theme
end

----------------------------------------------------
-- Cloud non-ui methods
----------------------------------------------------

instance.set = function( variable, value )
	if "debugEnabled" == variable then
		instance.cc.debugEnabled = value
	end	
end

instance.setAutoCreateAccounts = function( trueFalse )
	instance._autoCreateAccounts = trueFalse
end

----
-- callbacks
----

instance.updateCache = function(section, data)
	local doReload = 0
	-- load cache first
	instance._cache = instance._cloudHelper._loadCloudDataFromFile()
	-- depending on section, we update the cache
	if section=="user" and data then
		instance._cache._userCache = data
		doReload = 0
		instance._cacheCounter = instance._cacheCounter + 1
	end
	if section == "achievements" and data then
		instance._cache._achievementsCache = data
		if instance._currentSection == instance.conf.S_ACHIEVEMENTS or instance._currentSection == instance.conf.S_FRIENDS then
			doReload = 0
		end
		instance._cacheCounter = instance._cacheCounter + 1
	end
	if section == "leaderboards" and data then
		instance._cache._leaderboardsCache = data
		instance._cache._leaderboardDetailsCache = {}
		
		for i = 1, #data do
			instance._cache._leaderboardDetailsCache[ data[i]._id ] = {}
		end
		
		if instance._currentSection == instance.conf.S_LEADERBOARDS then
			doReload = 0
		end
		instance._cacheCounter = instance._cacheCounter + 1
	end
	if section == "leaderboardDetails" and data then
		if data[ 1 ] and data[ 1 ]._id then
			instance._cache._leaderboardDetailsCache [ data[ 1 ].leaderboard_id ] = data
		end
		doReload = 0
	end
	if section == "friendDetails" and data then
		if data and data._id then
			instance._cache._friendDetailsCache [ data._id ] = data
		end
		doReload = 0
	end	
	
	if section == "friends" and data then
		instance._cache._friendsCache = data
		if instance._cache._friendsCache and #instance._cache._friendsCache > 0 then

			if nil == instance._cache._friendDetailsCache then
				instance._cache._friendDetailsCache = {}
			end

			for i = 1, #data do
				instance._cache._friendDetailsCache[ data[i].friend_id ] = {}
			end

			for i=1, #instance._cache._friendsCache do
				instance.cc.getProfile( instance._cache._friendsCache[ i ].friend_id )
			end
		end
		if instance._currentSection == instance.conf.S_FRIENDS then
			doReload = 0
		end
		instance._cacheCounter = instance._cacheCounter + 1
	end
	if section == "news" and data then
		instance._cache._newsCache = data
			doReload = 0
			instance._cacheCounter = instance._cacheCounter + 1
	end
	if section == "info" and data then
		instance._cache._infoCache = data
		doReload = 0
		instance._cacheCounter = instance._cacheCounter + 1
	end
	
	if instance._cacheCounter >= 6 then
		doReload = 1
	end
	
	-- write the data to cache
	instance._cloudHelper._saveCloudDataToFile( instance._cache )

	if doReload == 1 and instance._didReload == 0 then
		instance._didReload = 1
		-- refresh the current view.
		if instance._currentSection == instance.conf.S_ACHIEVEMENTS then
			instance.showAchievements()
		elseif instance._currentSection == instance.conf.S_FRIENDS then
			instance.showFriends()
		elseif instance._currentSection == instance.conf.S_LEADERBOARDS then
			instance.showLeaderboards()
		elseif instance._currentSection == instance.conf.S_LEADERBOARD_DETAILS then
			_leaderboardDetails.show( instance )
		elseif instance._currentSection == instance.conf.S_NEWS then
			_news.show( instance )
		end
	
	end
	
end

return instance