; ___________________________________
;¦¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
;¦ <*> Network Management v1.45      |
;¦     with 666 lines of code!       |
;¦___________________________________|
;¦¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
;¦ <?> by fiz [remi@exomel.com]      |
;¦     formerly known as Kw1KSiLvR   |
;¦                                   |
;¦ <@> http://exomel.com/code/       |
;¦ <#> irc.pixelarmy.us              |
;¦      on #pixelarmy & #skinnables  |
;¦___________________________________|
;¦¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
;¦ <!> /netman to open the setup     |
;¦___________________________________|
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;
; ### Changes through versions ###
;
;
;  v1.45
;
; + Added support for auto-joining
;   password protected channels (+k)
;   by storing the channel name and
;   the password after. Like that:
;
;   #my_channel my_password
;
;
; / WARNING! By upgrading to this version,
; / you will have to re-enter all your
; / channels manually since the channel
; / storing system has changed.
;
;
; ---------------------------------
;  v1.4
;
; + Added a custom "identd" option
;   for each network. You can now have
;   a different userid for every network.
;   Only works if mIRC has it enabled.
;   "ALT+O, Connect, Identd"
;
;
; ---------------------------------
;
;  v1.34
;
; + Added a nicely documented "Readme" file!
; + Added support for using $input
;   in a login command.
; * Modified the dialog layout.
; ! Fixed a bug related to a personal alias
;   accidentally included in the file.
;
; ---------------------------------
;
; v1.33
;
; + Added "Connect" and "Connect All" buttons in the dialog.
; + Added a nice "About" dialog!
;
; ---------------------------------
;
; v1.32 (non released)
;
; ! Some fixes to the menu and the
;   multi-connect feature.
;
; ---------------------------------
;
; v1.31 (first release on mircscripts.org)
;
; + Added an option to decide to whether integrate
;   Netman into the Status Window popup.
; ! Improved the Netman_NetPerform alias. Let you
;   perform commands that are not auto-enabled.
;
; ---------------------------------
;
; v1.3
;
; + Added "minimize on join" function to auto-join channels
; ! Fixed an auto-login bug.
;
; ---------------------------------
;
; v1.2
;
; ! Fixed a weird bug. (thanks Jeus again :P)
; ! Fixed a lot of bugs with the ini-writing (thanks Jeus ;)
; ! Now, must have all the minimal settings to 
;   connect (nick, anick, email, fullname and server)
;   If not, skip the network.
;
; ---------------------------------
;
; v1.1
;
; + Added support for dynamic status popup.
; + Added support for nicks, fullnames, etc.
; + Added support for a specific server.
;
;
; ---------------------------------
;
; v1.0
; 
; * First release on http://fiz.blackedout.org
;
;----------------------------------------------

menu status,channel {
  -
  $iif($readini($netman_file,Netman_setup,popup),&Connect)
  .&All ( $+ $netman_totalnets total):netman_connect2 all
  .&Netman setup:netman
  .-
  .$submenu($netman_somenets($1))
  $iif(($status == connected && $readini($netman_file,Netman_setup,popup)),$network $chr(58) Network)
  .$iif($netman_get($network,login),Login):netman_netperform * $network login
  .$iif($netman_get($network,umodes),Set usermodes):netman_netperform * $network umodes
  .$iif($netman_get($network,chans),Join channels):netman_netperform * $network join
  -
}

alias netman_somenets {
  var %n = $netman_ini(0)
  var %n2
  var %i = 1
  while (%i <= %n) {
    %n2 = $netman_ini(%i)
    if ($1 = %i) { 
      if (%n2 !== Netman_setup) {
        return & $+ %n2 ( $+ $netman_get(%n2,nick) $+ ): netman_connect2 %i
      }

      ; ### prevent from displaying something (that's the only way I think I can)
      else { return .:. }
    }

    inc %i
  }
}
alias netman_totalnets {
  var %n = $netman_ini(0)
  var %i = 1
  var %a = 0
  while (%i <= %n) {
    if ($netman_ini(%i) != Netman_setup) {
      inc %a
    }
    inc %i
  }
  return %a
}

alias netman_connect2 {
  ;  echo connecting to: $netman_ini($1-)
  if ($1 = all) { var %i = $netman_ini(0) | var %a = 1 }
  else { var %a = $1 }
  :star
  if ($status != disconnected) { var %param = -m }
  else { var %param = $null }

  var %n = $netman_ini(%a)

  if (%n = Netman_setup) { inc %a | goto star }

  var %nick = $netman_get(%n,nick)
  var %altnick = $netman_get(%n,altnick)
  var %fullname = $netman_get(%n,fullname)
  var %email = $netman_get(%n,email)
  var %server = $$netman_get(%n,server)

  if (!%nick) || (!%altnick) || (!%fullname) || (!%email) || (!%server) {
    if (%a < %i) { inc %a | goto star }
  }

  server %param %server -i %nick %altnick %email %fullname
  if ($1 = all) && (%a < %i) { inc %a | goto star }
  else return
}

;### keeping the old dialog here... to remember how it started :'(

#netman_old off

dialog netman {
  title $netman_t [/netman]
  size -1 -1 190 228
  option dbu
  list 1, 6 10 69 168, size
  button "&Add", 8, 6 181 33 10
  button "&Rem", 9, 42 181 33 10, disable
  button "&Connect", 30, 6 194 33 10, disable
  button "Connect All", 31, 42 194 33 10
  text "Server:", 25, 82 11 20 8, disable
  edit "", 26, 109 10 73 10, disable
  text "Nick:", 16, 82 28 13 8, disable
  edit "", 17, 109 27 73 10, disable autohs
  text "Alt. Nick:", 18, 82 39 23 8, disable
  edit "", 19, 109 38 73 10, disable autohs
  text "Fullname:", 20, 82 50 25 8, disable
  edit "", 24, 109 49 73 10, disable autohs
  text "E-mail:", 22, 82 61 17 8, disable
  edit "", 21, 109 60 73 10, disable autohs
  check "Set usermodes:", 7, 82 72 48 10, disable
  edit "", 6, 131 72 34 10, disable autohs
  check "Login command:", 5, 82 84 50 10, disable
  edit "", 23, 92 95 73 10, disable autohs
  check "Auto-join channels on connect", 11, 82 109 83 10, disable
  list 2, 83 120 99 58, disable size
  check "Minimize channels on join", 28, 82 183 97 8, disable
  button "Add", 4, 82 194 22 10, disable
  button "Rem", 3, 107 194 22 10, disable
  button "&Up", 14, 133 194 22 10, disable
  button "&Down", 15, 159 194 22 10, disable
  box "Networks", 12, 2 2 77 206
  box "Settings", 13, 78 2 109 206
  button "Close", 10, 150 213 37 12, ok
  button "?", 32, 135 213 13 12
  check "&Integrate into Status Window popup", 29, 2 214 99 10
  text "------------------------------------------------------", 27, 78 20 108 5, disable
}

#netman_old end

dialog netman {
  title $netman_t [/netman]
  size -1 -1 200 178
  option dbu
  list 1, 6 10 69 120, size
  button "&Add", 8, 6 133 33 10
  button "&Rem", 9, 42 133 33 10, disable
  button "&Connect", 30, 6 146 33 10, disable
  button "Connect All", 31, 42 146 33 10
  box "Networks", 12, 2 2 77 158
  tab "Infos", 33, 82 9 111 145
  text "Server:", 25, 87 26 20 8, disable tab 33
  edit "", 26, 87 34 101 10, disable tab 33
  text "Nick:", 16, 87 46 13 8, disable tab 33
  edit "", 17, 87 54 101 10, disable tab 33 autohs
  text "Alt. Nick:", 18, 87 66 23 8, disable tab 33
  edit "", 19, 87 74 101 10, disable tab 33 autohs
  text "Fullname:", 20, 87 86 25 8, disable tab 33
  edit "", 24, 87 94 101 10, disable tab 33 autohs
  text "E-mail:", 22, 87 106 17 8, disable tab 33
  edit "", 21, 87 114 101 10, disable tab 33 autohs
  text "Identd (if enabled in mIRC Options)", 34, 87 126 87 8, disable tab 33
  edit "", 35, 87 134 101 10, disable tab 33 autohs
  tab "Advanced", 27
  check "Set usermodes:", 7, 87 28 48 10, disable tab 27
  edit "", 6, 136 28 34 10, disable tab 27 autohs
  check "Login command:", 5, 87 40 50 10, disable tab 27
  edit "", 23, 97 51 73 10, disable tab 27 autohs
  check "Auto-join channels on connect", 11, 87 65 83 10, disable tab 27
  list 2, 88 76 99 50, disable tab 27 size
  check "Minimize channels on join", 28, 86 128 97 8, disable tab 27
  button "Add", 4, 86 139 22 10, disable tab 27
  button "Rem", 3, 111 139 22 10, disable tab 27
  button "&Up", 14, 137 139 22 10, disable tab 27
  button "&Down", 15, 163 139 22 10, disable tab 27
  box "Network Settings", 13, 78 2 120 158
  check "&Integrate into Status Window popup", 29, 3 165 99 10
  button "?", 32, 146 163 13 12
  button "Close", 10, 161 163 37 12, ok

}


on *:dialog:netman:init:0:{

  ; list the networks in the main list
  netman_loadnets


  ; verify integration
  var %h = $netman_ini(Netman_setup)
  if (!%h) { netman_set Netman_setup popup 1 }
  var %s = $readini($netman_file,Netman_setup,popup)
  did $iif(%s = 1,-c,-u) $dname 29
}
alias netman_t { return Network Management }
alias netman_ver { return 1.45 }

; we have to keep this alias :]
alias netman { dialog -m netman netman }

alias netman_file {

  ; All-Windows-Version Compliant ;)
  ;
  ; /me loves standards.

  var %s = " $+ $scriptdir $+ netman.ini $+ "
  return %s

}

;# get in .ini
alias -l netman_get { return $readini($netman_file,n,$$1,$$2-) }
;------------

;# write/remove in .ini
alias -l netman_set { if ($3) { writeini $netman_file $$1 $$2 $3- } | else { remini $netman_file $$1 $2 } }
;------------

;# check in .ini
alias -l netman_ini { return $ini($netman_file,$1) }
;------------

alias -l netman_loadnets {
  var %dname = netman
  var %n
  did -r %dname 1
  netman_clearall
  var %nets  = $netman_ini(0)
  var %a = 1
  while (%a <= %nets) {
    %n = $netman_ini(%a)
    if (%n != Netman_setup) {
      did -a %dname 1 %n
      inc %a
    }
    else { inc %a }
  }
  netman_perform b
  var %nn = $netman_totalnets

  if (%nn) { did -e %dname 31 }
  else { did -b %dname 31 }
}

on *:dialog:netman:edit:*:{
  var %vari
  var %d = $did
  if (%d = 6) %vari = umodes
  elseif (%d = 23) %vari = login
  elseif (%d = 17) %vari = nick
  elseif (%d = 19) %vari = altnick
  elseif (%d = 24) %vari = fullname
  elseif (%d = 21) %vari = email
  elseif (%d = 26) %vari = server
  elseif (%d = 35) %vari = identd

  netman_set $netman_net %vari $did($dname,$did)
}
on *:dialog:netman:sclick:*:{
  if ($did = 1) { netman_getinfo $netman_net }
  if ($did = 9) && ($iyt(Are you sure you want to remove $did($dname,1).seltext from the list?,$Netman_t,0)) { netman_set $did($dname,1).seltext | netman_loadnets }
  if ($did = 8) { 
    var %net = $$ipt(Enter network name:,$network,$Netman_t)

    ; /me likes Bob!
    netman_set %net me_likes bob

    ; we remove bob...
    netman_set %net me_likes

    ; we just wanted to create an header in the .ini file, with no vars.

    ; reload the networks
    netman_loadnets
  }
  if ($did = 28) {
    netman_set $netman_net minimize $netman_state($did) 
  }
  if ($did = 7) { 
    netman_set $netman_net aumodes $netman_state($did)
    did $iif($netman_state($did) = 1,-e,-b) $dname 6
  }
  if ($did = 5) { 
    netman_set $netman_net alogin $netman_state($did)
    did $iif($netman_state($did) = 1,-e,-b) $dname 23
  }
  if ($did = 4) { 
    var %c = $$ipt(Enter channel name,#,$Netman_t)
    if ($left(%c,1) != $chr(35)) { %c = $chr(35) $+ %c }
    var %chans = $netman_get($netman_net,chans)
    if (%chans) { netman_set $netman_net chans $addtok(%chans,%c,44) }
    else { netman_set $netman_net chans %c }
    netman_getinfo $netman_net
  }
  if ($did = 3) {
    var %chans = $netman_get($netman_net,chans)
    netman_set $netman_net chans $deltok(%chans,$did($dname,2).sel,44)
    netman_getinfo $netman_net
  }
  if ($did = 14) {
    var %chans = $netman_get($netman_net,chans)
    var %s = $did($dname,2).sel
    if (%s = 1) { return }
    netman_set $netman_net chans $switchtok(%chans,%s,$calc(%s -1),44)
    netman_getinfo $netman_net
    did -c netman 2 $calc(%s -1)
    netman_refreshbuttons
  }
  if ($did = 15) {
    var %chans = $netman_get($netman_net,chans)
    var %s = $did($dname,2).sel
    if (!$did($dname,2,$calc(%s +1)).text) { return }
    netman_set $netman_net chans $switchtok(%chans,%s,$calc(%s +1),44)
    netman_getinfo $netman_net
    did -c netman 2 $calc(%s +1)
    netman_refreshbuttons
  }
  if ($did = 2) { netman_refreshbuttons }
  if ($did = 11) { netman_set $netman_net ajoin $netman_state($did) | did $iif($netman_state($did),-e,-b) $dname 2,4,28  }
  if ($did = 29) {
    writeini $netman_file Netman_setup popup $netman_state(29)
  }
  if ($did = 30) {
    netman_connect2 $did($dname,1).sel
  }
  if ($did = 31) {
    netman_connect2 all
  }
  if ($did = 32) {
    netman_about Put that dialog on top baby! YAY!
  }
}
alias -l netman_refreshbuttons {
  if ($did(netman,2).seltext) { did -e $dname 3,14,15 }
}
alias -l netman_state { return $did(netman,$$1).state }
alias -l netman_net { return $did(netman,1).seltext }
alias -l netman_clearall {
  did -r netman 6,23,2,17,19,21,24,26,35
  did -u netman 11,5,7,28
}

; ### Mass Enabling/Disabling
alias netman_perform {
  did - [ $+ [ $$1 ] ] netman 9,6,23,11,2,3,4,5,7,13,16,17,18,19,20,21,22,24,25,26,28,30,34,35
}


; ### Get infos of the network
alias -l netman_getinfo {
  var %n = $$1
  var %aumodes = $netman_get(%n,aumodes)
  var %umodes = $netman_get(%n,umodes)
  var %alogin = $netman_get(%n,alogin)
  var %login = $netman_get(%n,login)
  var %ajoin = $netman_get(%n,ajoin)
  var %minimize = $netman_get(%n,minimize)
  var %achans = $netman_get(%n,chans)

  var %nick = $netman_get(%n,nick)
  var %altnick = $netman_get(%n,altnick)
  var %fullname = $netman_get(%n,fullname)
  var %email = $netman_get(%n,email)
  var %identd = $netman_get(%n,identd)
  var %server = $netman_get(%n,server)

  var %dname = netman
  netman_perform e
  netman_clearall
  if (%nick) { did -ra %dname 17 %nick }
  if (%altnick) { did -ra %dname 19 %altnick }
  if (%fullname) { did -ra %dname 24 %fullname }
  if (%email) { did -ra %dname 21 %email }
  if (%identd) { did -ra %dname 35 %identd }
  if (%server) { did -ra %dname 26 %server }

  did $iif(%aumodes = 1,-c,-u) %dname 7
  if (!%aumodes) { did -b %dname 6 }
  if (%umodes) { did -ra %dname 6 %umodes }
  did $iif(%alogin = 1,-c,-u) %dname 5
  if (!%alogin) { did -b %dname 23 }
  if (%login) { did -ra %dname 23 %login }
  didtok %dname 2 44 %achans
  did -b %dname 3,14,15
  did $iif(%ajoin = 1,-c,-u) %dname 11
  did -e %dname 28
  did $iif(%minimize,-c,-u) %dname 28
  if (!%ajoin) { did -b %dname 2,4,3,28 }
}


; ### I needed this since 1.0
alias netman_about {
  var %s = Network Management $netman_ver $+ $crlf $+ © 2003-2005 Remi Prevost (fiz) $+ $crlf $+ $crlf $+ All rights reserved. $+ $crlf $+ $crlf $+ remi@exomel.com $+ $crlf $+ http://exomel.com/code/
  var %x = $input(%s,100,About Network Management...)
}

;----------------------------------------------
;* THOSE are the "On Connect" events, so don't
;* remove them 'cause you'll be in trouble!
;*
;* Well, not in trouble but Netman would be
;* useless in that case :P
;----------------------------------------------


ON *:CONNECT:{
  if ($netman_isnet($network)) { netman_netperform $network }
}

on ^*:LOGON:*:{
  if ($netman_isnet($network)) {
    var %i = $netman_get(%n,identd)
    var %f = $netman_get(%n,fullname)
    if ($readini(mirc.ini,ident,active) == yes) {
      if (!%i) { %i = $readini(mirc.ini,ident,userid) }

      ;###### .raw USER identd "" "" :Fullname
      .raw USER %i "" "" : $+ %f
      haltdef
    }
    else {
      ;###### don't perform anything because the ident option is disabled in mIRC
    }
  }
}

;--------------------------------------------------;
;
; THE POWERFUL ALIAS.
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;
; /netman_netperform [*] <network> [action]
;
; <> Use "*" if you want the actions to be 
;    performed even if they are not "auto-enabled".
;
; <> <network> is the network
;
; <> <action> is the action you want to perform.
;
;  Actions (maybe more to come? not yet...):
;
;  - login
;  - umodes
;  - join
;
;--------------------------------------------------;

alias netman_netperform {

  var %goto
  var %n

  if ($1 == *) {

    if ($3 = join) { %goto = join }
    elseif ($3 = umodes) { %goto = umodes }
    elseif ($3 = login) { %goto = login }
  }

  if ($1 !== *) {

    if ($2 = join) { %goto = join }
    elseif ($2 = umodes) { %goto = umodes }
    elseif ($2 = login) { %goto = login }
  }

  if ($1 = *) { %n = $$2 }
  else { var %n = $$1 }

  var %aumodes = $netman_get(%n,aumodes)
  var %umodes = $netman_get(%n,umodes)
  var %alogin = $netman_get(%n,alogin)
  var %ajoin = $netman_get(%n,ajoin)
  var %minimize = $netman_get(%n,minimize)
  var %login = $netman_get(%n,login)
  var %achans = $netman_get(%n,chans)
  if ($left(%umodes,1) != +) && (%umodes) { %umodes = + $+ %umodes }

  if (%goto) { goto %goto }

  :umodes
  if ((%aumodes) || ($$1 == *)) && (%umodes) { mode $me %umodes | if (%goto = umodes) { goto end } }

  :login

  if ((%alogin) || ($$1 == *)) && (%login) { .timer $+ %n $+ _login -m 1 1 $eval(%login,2) | if (%goto = login) { goto end } }
  else { goto end }

  if ((%ajoin) || ($$1 == *)) && (%achans) { goto join }
  else { goto end }

  :join
  if ((!%ajoin) && ($$1 !== *)) || (!%achans) { goto end }
  var %a = 1
  var %chans = $gettok(%achans,0,44) 
  while (%a <= %chans) {

    var %c3 = $gettok(%achans,%a,44)

    if ($left(%c3,1) != $chr(35)) { %c3 = $chr(35) $+ %c3 }

    if (%c3 !ischan) { join $iif(%minimize,-n) %c3 }
    inc %a
  }
  :end
}


alias netman_isnet { 
  var %abc = $ini($netman_file,$$1)
  ;    \**\       
  ;     \**\   -- hehe what a link!
  ;      |**|     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     
  ;      |**|  
  ;      |**|   Hey! That's ascii ART!
  ;      |**|
  return %abc

  ;###############################
  ;
  ; No, seriously, I have to use
  ; that type of 'link' because
  ; the alias seems not to work
  ; properly made in another way.
  ;
  ; Eg:
  ;
  ; /return $ini(...) doesn't work!
  ;
  ;###############################


}

; switch tokens in string
;$switchtok(string,toknum1,toknum2,C)

; $switchtok(a b c d e f,3,4,32) returns: a b d c e f
; it switched token n°3 and n°4

;*
;* Useful for moving channels up and down.
;*

alias switchtok { var %x = $$1,%1 = $$2,%2 = $$3,%t = $$4,%t2 = $gettok(%x,%2,44),%t1 = $gettok(%x,%1,44) ,%c = $puttok(%x,%t1,%2,%t),%d = $puttok(%c,%t2,%1,%t) | return %d }

;; ########################################################################
;;
;; Those aliases are customizable if you want to use a custom input dialog.
;;
;; ########################################################################


; ############################################
; ##
; ## ** Text Parameter Entry
; ##
; ## $ipt(text,default_value,title)

alias ipt { return $input($$1,ied,$3,$2) }

; ############################################
; ##
; ## ** Boolean (True|False) Parameter Entry
; ##
; ## $iyt(text,title)

alias iyt { return $input($$1,yndq,$2) }

;#
;# End of the file
