module Svg.Path exposing
    ( Path(..)
    , startAt, end, endClosed
    , drawLineBy, drawLineTo
    , drawCircleArcAround, drawCircleArcAroundBy
    , jumpBy, jumpTo
    , drawArcBy, drawArcTo
    , drawCircleArcBy, drawCircleArcTo
    , custom, toString
    , PathBuilder
    )

{-|


# Building Paths

@docs Path
@docs startAt, end, endClosed
@docs drawLineBy, drawLineTo
@docs drawCircleArcAround, drawCircleArcAroundBy
@docs jumpBy, jumpTo


## Advanced

@docs drawArcBy, drawArcTo
@docs drawCircleArcBy, drawCircleArcTo
@docs custom, toString
@docs PathBuilder

-}

import Internal


{-| Commands for writing Paths.

You might want to use `PathBuilder` to build paths.

-}
type Path
    = JumpTo ( Float, Float ) Path
    | LineTo ( Float, Float ) Path
    | ArcTo
        ( Float, Float )
        { radiusX : Float
        , radiusY : Float
        , rotation : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
        Path
    | Custom String Path
    | EndClosed
    | End


{-| Builds Paths.

Start building paths with `startAt` and end it with `end`.

-}
type alias PathBuilder =
    ( ( Float, Float ), Path -> Path )


{-| Draw a circle arc around a center point
-}
drawCircleArcAround :
    ( Float, Float )
    ->
        { angle : Float
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawCircleArcAround ( x, y ) args ( ( x0, y0 ), fun ) =
    let
        radius =
            Internal.length ( x - x0, y - y0 )

        to =
            ( x0 - x, y0 - y )
                |> Internal.normalize
                |> Internal.rotateBy
                    (if args.clockwise then
                        args.angle

                     else
                        -args.angle
                    )
                |> Internal.scaleBy radius
                |> Internal.plus ( x, y )
    in
    drawCircleArcTo to
        { angle = args.angle
        , takeTheLongWay = args.angle > pi
        , clockwise = args.clockwise
        }
        ( ( x0, y0 ), fun )


{-| draw a circle arc around a relative center
-}
drawCircleArcAroundBy :
    ( Float, Float )
    ->
        { angle : Float
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawCircleArcAroundBy ( x, y ) args ( ( x0, y0 ), fun ) =
    drawCircleArcAround ( x0 + x, y0 + y ) args ( ( x0, y0 ), fun )


{-| draw a circle arc to a point
-}
drawCircleArcTo :
    ( Float, Float )
    ->
        { angle : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawCircleArcTo ( x, y ) args ( ( x0, y0 ), fun ) =
    let
        distance =
            Internal.length ( x - x0, y - y0 )

        angle2 =
            (pi - args.angle)
                / 2

        --Law of sins
        radius =
            sin angle2 * distance / sin args.angle
    in
    drawArcTo ( x, y )
        { radiusX = radius
        , radiusY = radius
        , rotation = 0
        , takeTheLongWay = args.takeTheLongWay
        , clockwise = args.clockwise
        }
        ( ( x0, y0 ), fun )


{-| draw a circle arc to a relative point
-}
drawCircleArcBy :
    ( Float, Float )
    ->
        { angle : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawCircleArcBy ( x, y ) args ( ( x0, y0 ), fun ) =
    drawCircleArcTo ( x0 + x, y0 + y ) args ( ( x0, y0 ), fun )


{-| draw an arc to a point
-}
drawArcTo :
    ( Float, Float )
    ->
        { radiusX : Float
        , radiusY : Float
        , rotation : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawArcTo to args ( _, fun ) =
    ( to, \path -> fun (ArcTo to args path) )


{-| draw an arc to a relative point
-}
drawArcBy :
    ( Float, Float )
    ->
        { radiusX : Float
        , radiusY : Float
        , rotation : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
    -> PathBuilder
    -> PathBuilder
drawArcBy ( x, y ) args ( ( x0, y0 ), fun ) =
    drawArcTo ( x0 + x, y0 + y ) args ( ( x0, y0 ), fun )


{-| jump to a point (without drawing)
-}
jumpTo : ( Float, Float ) -> PathBuilder -> PathBuilder
jumpTo pos ( _, fun ) =
    ( pos, \path -> fun (JumpTo pos path) )


{-| jump by a relative amount (without drawing)
-}
jumpBy : ( Float, Float ) -> PathBuilder -> PathBuilder
jumpBy ( x, y ) ( ( x0, y0 ), fun ) =
    jumpTo ( x0 + x, y0 + y ) ( ( x0, y0 ), fun )


{-| draw a line to a point
-}
drawLineTo : ( Float, Float ) -> PathBuilder -> PathBuilder
drawLineTo pos ( _, fun ) =
    ( pos, \path -> fun (LineTo pos path) )


{-| draw a line to a relative point
-}
drawLineBy : ( Float, Float ) -> PathBuilder -> PathBuilder
drawLineBy ( x, y ) ( ( x0, y0 ), fun ) =
    drawLineTo ( x0 + x, y0 + y ) ( ( x0, y0 ), fun )


{-| start building a path
-}
startAt : ( Float, Float ) -> PathBuilder
startAt pos =
    ( pos, JumpTo pos )


{-| custom path command.

You should only use this if you know what your doing.

    ```
    startAt (50,50)
    |> custom (\(x,y) -> ((x+10,y+10),"l10 10"))
    |> end
    ```

-}
custom :
    (( Float, Float ) -> ( ( Float, Float ), String ))
    -> PathBuilder
    -> PathBuilder
custom customFun ( from, fun ) =
    customFun from
        |> Tuple.mapSecond (\string -> \path -> fun (Custom string path))


{-| move back to the start and end the path
-}
endClosed : PathBuilder -> Path
endClosed ( _, fun ) =
    fun EndClosed


{-| end the path
-}
end : PathBuilder -> Path
end ( _, fun ) =
    fun End


{-| Convert the path to a string.

You can use it with elm/svg like this:

        Svg.path
            [ Svg.Attributes.d (toString path)]
            []

-}
toString : Path -> String
toString p0 =
    let
        rec path output =
            case path of
                JumpTo ( x, y ) p ->
                    ("M"
                        ++ String.fromFloat x
                        ++ " "
                        ++ String.fromFloat y
                    )
                        :: output
                        |> rec p

                LineTo ( x, y ) p ->
                    ("L"
                        ++ String.fromFloat x
                        ++ " "
                        ++ String.fromFloat y
                    )
                        :: output
                        |> rec p

                ArcTo ( toX, toY ) args p ->
                    ("A"
                        ++ String.fromFloat args.radiusX
                        ++ " "
                        ++ String.fromFloat args.radiusY
                        ++ " "
                        ++ String.fromFloat args.rotation
                        ++ " "
                        ++ (if args.takeTheLongWay then
                                "1"

                            else
                                "0"
                           )
                        ++ " "
                        ++ (if args.clockwise then
                                "1"

                            else
                                "0"
                           )
                        ++ " "
                        ++ (String.fromFloat toX
                                ++ " "
                                ++ String.fromFloat toY
                           )
                    )
                        :: output
                        |> rec p

                Custom string p ->
                    string
                        :: output
                        |> rec p

                EndClosed ->
                    "Z" :: output

                End ->
                    output
    in
    rec p0 []
        |> List.reverse
        |> String.join " "
