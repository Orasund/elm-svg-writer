module Svg.Writer exposing (..)

import Html exposing (Attribute, Html)
import Html.Attributes
import Svg.Path exposing (Path)


type alias SvgAttribute =
    ( String, String )


type SvgNode
    = SvgNode
        { name : String
        , attributes : List SvgAttribute
        , content : List SvgNode
        }


path : List SvgAttribute -> Path -> SvgNode
path attrs p =
    SvgNode
        { name = "path"
        , attributes = ( "d", Svg.Path.toString p ) :: attrs
        , content = []
        }


toHtml : List (Attribute msg) -> List SvgNode -> Html msg
toHtml attrs list =
    let
        rec (SvgNode node) =
            Html.node node.name
                (node.attributes
                    |> List.map (\( name, value ) -> Html.Attributes.attribute name value)
                )
                (node.content |> List.map rec)
    in
    list
        |> List.map rec
        |> Html.node "svg" attrs
