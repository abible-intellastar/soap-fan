using xml
using web

class SOAPEnvelope {

  // WSDL
  const WSDL wsdl

  XDoc? soapResponse

  // SOAP Request Variables
  XElem? soapRequest
  SOAPElement[] reqElements := [,]
  XElem? header
  XElem? body

  // SOAP Environment and Namespace vars
  XNs soapenv := XNs("soapenv", `http://schemas.xmlsoap.org/soap/envelope/`)
  XNs ns

  Uri? targetUri
  Str? soapAction

  new make(WSDL wsdl) {
    this.wsdl = wsdl
    this.ns = XNs("ns", Uri(wsdl.schema.targetNamespace))

    _init
  }

  Void _init() {
    this.header = XElem("Header", soapenv)
    this.body = XElem("Body", soapenv)

    this.soapRequest = XElem("Envelope", soapenv)
    this.soapRequest.addAttr("xmlns:soapenv", "http://www.resourcedm.com/RDMPlantTDB/2009/03/13/")
    this.soapRequest.addAttr("xmlns:ns", wsdl.schema.targetNamespace)

    wsdlScheme := wsdl.uri.scheme
    wsdlHost := wsdl.uri.host
    wsdlPort := wsdl.uri.port

    this.targetUri = Uri.fromStr("$wsdlScheme://$wsdlHost:$wsdlPort$wsdl.service.port.uri.pathStr?$wsdl.service.port.uri.queryStr")

    this.soapResponse = XDoc()
  }

  Void send() {
    // Sanity Check
    if (this.targetUri == null) throw ArgErr("No target URI available")
    echo(targetUri)

    // Define Client
    WebClient client := WebClient(this.targetUri)

    // Define Headers
    client.reqHeaders.add("SOAPAction", this.soapAction)

    // POST Request
    client.postStr(this.soapRequest.writeToStr)

    // Get the response
    this.soapResponse = XParser(client.resIn).parseDoc(true)

   // DEBUG
    //echo(client.resCode)
    //echo(client.resIn.readAllStr)
    //echo(soapResponse.writeToStr)

  }

  This createRequest(Str op, [Str:Obj]? vals := null) {
    _init

    operation := wsdl.portType.operations.find | oper | { oper.name == op }

    binding := wsdl.binding.opsMap[operation.name]

    this.soapAction = binding.soapAction.toStr
//    this.targetUri = wq

    reqMsgName := operation.inputMessage.split(':').last
    resMsgName := operation.outputMessage.split(':').last

    reqBody := XElem(operation.name, ns)
    this.reqElements = getElements(reqMsgName)

    reqElements.each | element | {
      Obj? elementVal

      if (vals != null) {
        elementVal = vals.find | val, key | { key == element.name }
        element.setVal(elementVal)
      }

//      reqBody = reqBody.add(XElem(element.name, ns))
      reqBody = reqBody.add(element)
//      reqBody = reqBody.add(element.setVal(elementVal))
    }

//    //Assemble body
    body.add(reqBody)

    //Assemble envelope
    soapRequest.add(header).add(body)

    //Assemble Document
//    this.soapDoc = XDoc(soapRequest)

    return this
  }

  Str[] fields() {
    list := [,]
    reqElements.each | element | { list.add(element.name)  }

    return list
  }

//  This addVars([Str:Obj] vars) {
//    echo("Vals to assign: $vars.keys")
//
//    reqElements.each | element | {
//
//      echo("Element $element.name")
//      if (vars[element.name] != null) element.setVal(vars[element.name])
//
//    }
//
//    reqBody := XElem(this.soapAction.split('=').last, ns)
//
//    reqElements.each | element | {
//      reqBody = reqBody.add(XElem(element.name, ns))
//    }
//
//    body.add(reqBody)
//
//    return this
//  }

  private SOAPElement[] getElements(Str msgName) {
    SOAPElement[] elements := [,]
    message := wsdl.messages.find | msg | { msg.name == msgName }
    req := wsdl.schema.reqs.find | req | { req.name == message.element.split(':').last }

    if ((req is WSDLElement) && (req as WSDLElement).type is WSDLComplexType) {
      ((req as WSDLElement).type as WSDLComplexType).sequence.each | element | {
        elements.add(SOAPElement(element.name, element.type))
      }
    }

//    if (req is WSDLComplexType) {
//      (req as WSDLComplexType).sequence.each | element | {
//        elements.add(SOAPElement(element.name, element.type))
//      }
//    }

    return elements
  }

}

class SOAPElement : XElem {

  const Type type
  Obj? val

  const Bool isEnum

  const Str[] enumAvail

  new make(Str name, Obj typeObj) : super(this.name, ns) {
    this.name = name

    Bool isEnum := false
    Str[] enumAvail := [,]
    Type? type

    if (typeObj is Str) {
      switch (typeObj) {
        case "s:int":
          type = Int#
        case "s:dateTime":
          type = DateTime#
        default:
          type = Str#
      }
    }
    else if (typeObj is WSDLSimpleType) {
      switch ((typeObj as WSDLSimpleType).restriction) {
        case "s:string":
          type = Str#
          isEnum = true
          enumAvail = (typeObj as WSDLSimpleType).availValues
        default:
      }
    }

    this.isEnum = isEnum
    this.enumAvail = enumAvail
    this.type = type
  }

  This setVal(Obj? val) {
    add(XText(val.toStr))
    // TODO Type validation
//    if (val.typeof != type) {
//      throw ArgErr("Invalid SOAP Element value $val of type $val.typeof Expecting $type")
//    }

    // TODO Enumeration Check

    // TODO Validate value

    return this
  }

}