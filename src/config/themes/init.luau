local Themes = {
    ["Light"] = require("@config/themes/light"),
    ["Dark"] = require("@config/themes/dark"),
}
export type Theme = keyof<typeof(Themes)>
return Themes :: { [Theme]: any }
