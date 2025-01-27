module Svg.Path exposing
    ( join
    , closePath
    , moveTo, relativeMoveTo
    , lineTo, relativeLineTo
    , horizontalLineTo, relativeHorizontalLineTo
    , verticalLineTo, relativeVerticalLineTo
    , curveTo, relativeCurveTo
    , quadraticBezierCurveTo, relativeQuadraticBezierCurveTo
    , smoothCubicBezierCurveTo, relativeSmoothCubicBezierCurveTo
    , cubicBezierCurveTo, relativeCubicBezierCurveTo
    , arcTo, relativeArcTo
    )

{-|


## Join

@docs join


## Close Path

@docs closePath


## Move

@docs moveTo, relativeMoveTo


## Line

@docs lineTo, relativeLineTo
@docs horizontalLineTo, relativeHorizontalLineTo
@docs verticalLineTo, relativeVerticalLineTo


# Quadratic Bézier curve

@docs curveTo, relativeCurveTo
@docs quadraticBezierCurveTo, relativeQuadraticBezierCurveTo


# Cubic Bézier curve

@docs smoothCubicBezierCurveTo, relativeSmoothCubicBezierCurveTo
@docs cubicBezierCurveTo, relativeCubicBezierCurveTo


# Arc

@docs arcTo, relativeArcTo

-}


{-|

    join =
        String.join " "

-}
join : List String -> String
join =
    String.join " "


{-| -}
moveTo : ( Float, Float ) -> String
moveTo ( x, y ) =
    [ "M"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
relativeMoveTo : ( Float, Float ) -> String
relativeMoveTo ( x, y ) =
    [ "m"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
lineTo : ( Float, Float ) -> String
lineTo ( x, y ) =
    [ "L"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
relativeLineTo : ( Float, Float ) -> String
relativeLineTo ( x, y ) =
    [ "l"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
horizontalLineTo : Float -> String
horizontalLineTo x =
    [ "H"
    , String.fromFloat x
    ]
        |> String.join " "


{-| -}
relativeHorizontalLineTo : Float -> String
relativeHorizontalLineTo x =
    [ "h"
    , String.fromFloat x
    ]
        |> String.join " "


{-| -}
verticalLineTo : Float -> String
verticalLineTo y =
    [ "V"
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
relativeVerticalLineTo : Float -> String
relativeVerticalLineTo y =
    [ "v"
    , String.fromFloat y
    ]
        |> String.join " "


{-| -}
cubicBezierCurveTo :
    ( Float, Float )
    ->
        { point1 : ( Float, Float )
        , point2 : ( Float, Float )
        }
    -> String
cubicBezierCurveTo ( x, y ) args =
    let
        ( x1, y1 ) =
            args.point1

        ( x2, y2 ) =
            args.point2
    in
    [ "C"
    , String.fromFloat x1
    , String.fromFloat y1
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
relativeCubicBezierCurveTo :
    ( Float, Float )
    ->
        { point1 : ( Float, Float )
        , point2 : ( Float, Float )
        }
    -> String
relativeCubicBezierCurveTo ( x, y ) args =
    let
        ( x1, y1 ) =
            args.point1

        ( x2, y2 ) =
            args.point2
    in
    [ "c"
    , String.fromFloat x1
    , String.fromFloat y1
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
smoothCubicBezierCurveTo :
    ( Float, Float )
    ->
        { point : ( Float, Float )
        }
    -> String
smoothCubicBezierCurveTo ( x, y ) args =
    let
        ( x2, y2 ) =
            args.point
    in
    [ "S"
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
relativeSmoothCubicBezierCurveTo :
    ( Float, Float )
    ->
        { point : ( Float, Float )
        }
    -> String
relativeSmoothCubicBezierCurveTo ( x, y ) args =
    let
        ( x2, y2 ) =
            args.point
    in
    [ "s"
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
quadraticBezierCurveTo :
    ( Float, Float )
    ->
        { point : ( Float, Float )
        }
    -> String
quadraticBezierCurveTo ( x, y ) args =
    let
        ( x2, y2 ) =
            args.point
    in
    [ "Q"
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
relativeQuadraticBezierCurveTo :
    ( Float, Float )
    ->
        { point : ( Float, Float )
        }
    -> String
relativeQuadraticBezierCurveTo ( x, y ) args =
    let
        ( x2, y2 ) =
            args.point
    in
    [ "q"
    , String.fromFloat x2
    , String.fromFloat y2
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
curveTo : ( Float, Float ) -> String
curveTo ( x, y ) =
    [ "T"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
relativeCurveTo : ( Float, Float ) -> String
relativeCurveTo ( x, y ) =
    [ "t"
    , String.fromFloat x
    , String.fromFloat y
    ]
        |> String.join ""


{-| -}
arcTo :
    ( Float, Float )
    ->
        { radiusX : Float
        , radiusY : Float
        , angle : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        }
    -> String
arcTo ( endX, endY ) args =
    let
        stringFromBool : Bool -> String
        stringFromBool b =
            if b then
                "1"

            else
                "0"
    in
    [ "A"
    , String.fromFloat args.radiusX
    , String.fromFloat args.radiusY
    , String.fromFloat args.angle
    , stringFromBool args.takeTheLongWay
    , stringFromBool args.clockwise
    , String.fromFloat endX
    , String.fromFloat endY
    ]
        |> String.join " "


{-| -}
relativeArcTo :
    { radiusX : Float
    , radiusY : Float
    , angle : Float
    , takeTheLongWay : Bool
    , clockwise : Bool
    , endAt : ( Float, Float )
    }
    -> String
relativeArcTo args =
    let
        stringFromBool : Bool -> String
        stringFromBool b =
            if b then
                "1"

            else
                "0"

        ( endX, endY ) =
            args.endAt
    in
    [ "a"
    , String.fromFloat args.radiusX
    , String.fromFloat args.radiusY
    , String.fromFloat args.angle
    , stringFromBool args.takeTheLongWay
    , stringFromBool args.clockwise
    , String.fromFloat endX
    , String.fromFloat endY
    ]
        |> String.join " "


{-| -}
closePath : String
closePath =
    "Z"
