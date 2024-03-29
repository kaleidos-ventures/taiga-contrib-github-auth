###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos INC
###

AUTH_URL = "https://github.com/login/oauth/authorize"

GithubLoginButtonDirective = ($window, $params, $location, $config, $events, $confirm,
                              $auth, $navUrls, $loader) ->
    # Login or registar a user with his/her github account.
    #
    # Example:
    #     tg-github-login-button()
    #
    # Requirements:
    #   - ...

    link = ($scope, $el, $attrs) ->
        clientId = $config.get("gitHubClientId", null)

        loginOnSuccess = (response) ->
            if $params.next and $params.next != $navUrls.resolve("login")
                nextUrl = $params.next
            else
                nextUrl = $navUrls.resolve("home")

            $events.setupConnection()

            $location.search("next", null)
            $location.search("token", null)
            $location.search("state", null)
            $location.search("code", null)
            $location.path(nextUrl)

        loginOnError = (response) ->
            $location.search("state", null)
            $location.search("code", null)
            $loader.pageLoaded()

            if response.data._error_message
                $confirm.notify("light-error", response.data._error_message )
            else
                $confirm.notify("light-error", "Our Oompa Loompas have not been able to get you
                                                credentials from GitHub.")  #TODO: i18n

        loginWithGitHubAccount = ->
            type = $params.state
            code = $params.code
            token = $params.token

            return if not (type == "github" and code)
            $loader.start(true)

            data = {code: code, token: token}
            $auth.login(data, type).then(loginOnSuccess, loginOnError)

        loginWithGitHubAccount()

        $el.on "click", ".button-auth", (event) ->
            redirectToUri = $location.absUrl()
            url = "#{AUTH_URL}?client_id=#{clientId}&redirect_uri=#{redirectToUri}&state=github&scope=user:email"
            $window.location.href = url

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        template: ""
    }

module = angular.module('taigaContrib.githubAuth', [])
module.directive("tgGithubLoginButton", ["$window", '$routeParams', "$tgLocation", "$tgConfig", "$tgEvents",
                                         "$tgConfirm", "$tgAuth", "$tgNavUrls", "tgLoader",
                                         GithubLoginButtonDirective])
