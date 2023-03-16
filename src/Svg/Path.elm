module Svg.Path exposing (..)


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


type alias PathBuilder =
    ( ( Float, Float ), Path -> Path )


drawSemicircleTo : ( Float, Float ) -> { clockwise : Bool } -> PathBuilder -> PathBuilder
drawSemicircleTo to args ( ( x1, y1 ), fun ) =
    let
        ( x2, y2 ) =
            to

        distance =
            (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) |> sqrt
    in
    ( to
    , \path ->
        fun
            (ArcTo to
                { radiusX = distance / 2
                , radiusY = distance / 2
                , rotation = 0
                , takeTheLongWay = False
                , clockwise = args.clockwise
                }
                path
            )
    )


drawSemicircleBy : ( Float, Float ) -> { clockwise : Bool } -> PathBuilder -> PathBuilder
drawSemicircleBy ( x, y ) args ( ( x0, y0 ), fun ) =
    drawSemicircleTo ( x0 + x, y0 + y ) args ( ( x0, y0 ), fun )


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


jumpTo : ( Float, Float ) -> PathBuilder -> PathBuilder
jumpTo pos ( _, fun ) =
    ( pos, \path -> fun (JumpTo pos path) )


jumpBy : ( Float, Float ) -> PathBuilder -> PathBuilder
jumpBy ( x, y ) ( ( x0, y0 ), fun ) =
    jumpTo ( x0 + x, y0 + y ) ( ( x0, y0 ), fun )


drawLineTo : ( Float, Float ) -> PathBuilder -> PathBuilder
drawLineTo pos ( _, fun ) =
    ( pos, \path -> fun (LineTo pos path) )


drawLineBy : ( Float, Float ) -> PathBuilder -> PathBuilder
drawLineBy ( x, y ) ( ( x0, y0 ), fun ) =
    drawLineTo ( x0 + x, y0 + y ) ( ( x0, y0 ), fun )


startAt : ( Float, Float ) -> PathBuilder
startAt pos =
    ( pos, JumpTo pos )


custom :
    (( Float, Float ) -> ( ( Float, Float ), String ))
    -> PathBuilder
    -> PathBuilder
custom customFun ( from, fun ) =
    customFun from
        |> Tuple.mapSecond (\string -> \path -> fun (Custom string path))


endClosed : PathBuilder -> Path
endClosed ( _, fun ) =
    fun EndClosed


end : PathBuilder -> Path
end ( _, fun ) =
    fun End


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
