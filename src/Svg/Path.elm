module Svg.Path exposing (..)


type Path
    = JumpTo ( Float, Float ) Path
    | LineTo ( Float, Float ) Path
    | Arc
        { radiusX : Float
        , radiusY : Float
        , rotation : Float
        , takeTheLongWay : Bool
        , clockwise : Bool
        , to : ( Float, Float )
        }
        Path
    | CustomTo
        { to : ( Float, Float )
        , name : String
        , arguments : List String
        }
        Path
    | EndClosed
    | End


type alias PathBuilder =
    ( ( Float, Float ), Path -> Path )


semicircle : { to : ( Float, Float ), clockwise : Bool } -> PathBuilder -> PathBuilder
semicircle args ( ( x1, y1 ), fun ) =
    let
        ( x2, y2 ) =
            args.to

        distance =
            (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) |> sqrt
    in
    ( args.to
    , \path ->
        fun
            (Arc
                { radiusX = distance / 2
                , radiusY = distance / 2
                , rotation = 0
                , takeTheLongWay = False
                , clockwise = args.clockwise
                , to = args.to
                }
                path
            )
    )


startAt : ( Float, Float ) -> PathBuilder
startAt pos =
    ( pos, JumpTo pos )


jumpTo : ( Float, Float ) -> PathBuilder -> PathBuilder
jumpTo pos ( _, fun ) =
    ( pos, \path -> fun (JumpTo pos path) )


lineTo : ( Float, Float ) -> PathBuilder -> PathBuilder
lineTo pos ( _, fun ) =
    ( pos, \path -> fun (LineTo pos path) )


custom :
    { to : ( Float, Float )
    , name : String
    , arguments : List String
    }
    -> PathBuilder
    -> PathBuilder
custom args ( _, fun ) =
    ( args.to, \path -> fun (CustomTo args path) )


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

                Arc arc p ->
                    ("A"
                        ++ String.fromFloat arc.radiusX
                        ++ " "
                        ++ String.fromFloat arc.radiusY
                        ++ " "
                        ++ String.fromFloat arc.rotation
                        ++ " "
                        ++ (if arc.takeTheLongWay then
                                "1"

                            else
                                "0"
                           )
                        ++ " "
                        ++ (if arc.clockwise then
                                "1"

                            else
                                "0"
                           )
                        ++ (arc.to
                                |> (\( toX, toY ) ->
                                        String.fromFloat toX
                                            ++ " "
                                            ++ String.fromFloat toY
                                   )
                           )
                    )
                        :: output
                        |> rec p

                CustomTo args p ->
                    ((args.name
                        :: args.arguments
                        |> String.join " "
                     )
                        ++ " "
                        ++ (args.to
                                |> (\( toX, toY ) ->
                                        String.fromFloat toX
                                            ++ " "
                                            ++ String.fromFloat toY
                                   )
                           )
                    )
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
