#! /usr/bin/env fan

using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "soap"
    summary = "Description of this pod"
    version = Version("1.0")
    // These values are optional, but recommended
    // See: http://fantom.org/doc/docLang/Pods#meta
    meta = [
    //   "org.name":     "My Org",
    //   "org.uri":      "http://myorg.org/",
    //   "proj.name":    "My Project",
    //   "proj.uri":     "http://myproj.org/",
    //   "license.name": "Apache License 2.0",
      "vcs.name":     "Git",
      "vcs.uri":      "https://github.com/myorg/myproj"
    ]
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `fan/soap/`, `fan/soap/wdsl/`]
    // resDirs  = [,]
    // javaDirs = [,]
    // jsDirs   = [,]
    // docApi   = false   // defaults to 'true'
    // docSrc   = true    // defaults to 'false'
  }
}

#! /usr/bin/env fan
//
// Copyright (c) 2017, Intellastar
// All Rights Reserved
//
// History:
//   24 Feb 17   abible   Creation
//

using build

**
** Build: rdmExt
**
class Build : BuildPod
{
  new make()
  {
    podName = "rdmExt"
    summary = "TODO: summary of pod name..."
    version = Version("1.0")
    meta    = [
                "org.name":     "Intellastar",
                //"org.uri":      "http://acme.com/",
                //"proj.name":    "Project Name",
                //"proj.uri":     "http://acme.com/product/",
                "license.name": "Commercial",
              ]
    depends = ["sys 1.0",
               "haystack 2.1",
               "proj 2.1",
               "connExt 2.1",
               "gfx 1.0",
               "dom 1.0",
               "fwt 1.0",
               "chart 2.1",
               "webfwt 1.0",
               "web 1.0",
               "xml 1.0",
               "fresco 2.1"]
    srcDirs = [`fan/`,
               `fan/ui/`,
               `fan/wsdl/`,
               `fan/soap/`,
               `test/`]
    resDirs = [`locale/`,
               `lib/`]
    index   =
    [
      "proj.ext": "rdmExt::RdmExt",
      "proj.lib": "rdmExt::RdmLib",
    ]
  }
}