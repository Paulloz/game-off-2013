#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

Score = 0

class Wave
    constructor : ->
        @_mobs = []
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 400, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 400
        @_mobs.push window.DemCreepers.Pools.Gobs.get 300, 500
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 300
        @_mobs.push window.DemCreepers.Pools.Gobs.get 400, 400
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 500
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 600
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 700
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 800
        @_mobs.push window.DemCreepers.Pools.Gobs.get 500, 900

    update : (player, map) =>
        toDel = []
        _.map @_mobs, (mob, index) =>
            del = no
            _.map player._axes, (axe) =>
                if ((do axe._box.rect).collideRect (do mob._box.rect)) and axe._toGo >= 0
                    axe._toGo = -1
                    if --mob.pv <= 0
                        toDel.push index
                        del = yes
                        map.add mob
                        Score += 10
            if not del
                mob.update player, map._map
        toDel = toDel.sort (a, b) => b - a
        _.map toDel, (index) =>
            window.DemCreepers.Pools.Gobs.add (@_mobs.splice index, 1)[0]

    getToDraw : (viewport) => _.filter @_mobs, (mob) -> viewport.isPartlyInside mob._sprite

class HUD
    constructor : ->
        @_letters =new jaws.SpriteSheet
            image : 'assets/img/HUD-NUMBERSLETTERS.gif'
            frame_size : [15, 15]
            orientation : 'right'
        @_bg = new jaws.Sprite
            image : 'assets/img/HUD.gif'
            width: 400
            height: 20
            scale : 2
            x : 0
            y : 0
        @_score = new jaws.SpriteList
        _.map [0..10], (i) =>
            @_score.push new jaws.Sprite
                image : @_letters.frames[0]
                x : 760 - i * 20
                y : 5
                scale : 2

    update : =>
        _.map do ((String Score).split '').reverse, (n, i) =>
            (@_score.at i).setImage @_letters.frames[n]

    draw : =>
        do @_bg.draw
        do @_score.draw


class MainGame
    constructor : ->
        @_paused = no

    setup : =>
        [rows, cols] = [30, 40]
        @_viewport = new jaws.Viewport
            x : 0
            y : 20
            max_x : cols * window.DemCreepers.Config.TileSize[0]
            max_y : rows * window.DemCreepers.Config.TileSize[1]
        @_hud = new HUD
        @_map = new window.DemCreepers.Map rows, cols
        @_player = new window.DemCreepers.Player 100, 100
        @_wave = new Wave

    update : =>
        if jaws.pressedWithoutRepeat 'space'
            @_paused = not @_paused
        if not @_paused
            ### Player ###
            @_player.update @_viewport, @_map._map
            ### Monsters ###
            @_wave.update @_player, @_map
            ### Center viewport on Player ###
            @_viewport.centerAround @_player._box
            ### HUD ###
            do @_hud.update

    draw : =>
        do jaws.clear
        ### Draw the ground below everything ###
        @_viewport.drawTileMap @_map._ground
        ### Player ###
        window.DemCreepers.DrawBatch.add do @_player.getToDraw
        ### Ground ###
        _.map (do @_map.all), (tile) =>
            window.DemCreepers.DrawBatch.add tile
        ### Monsters ###
        window.DemCreepers.DrawBatch.add @_wave.getToDraw @_viewport
        @_viewport.apply =>
            ### Draw all ###
            window.DemCreepers.DrawBatch.draw @_viewport

        ### HUD ###
        do @_hud.draw

        ###
        # PAUSE
        ###
        #if @_paused

        (document.getElementById 'playerX').innerHTML = @_player.x
        (document.getElementById 'playerY').innerHTML = @_player.y
        (document.getElementById 'viewportX').innerHTML = @_viewport.x
        (document.getElementById 'viewportY').innerHTML = @_viewport.y

if window.DemCreepers?
    window.DemCreepers.MainGame = MainGame