// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._Common = function()
{
    this.getStyleForElement = function(element)
    {
        var visibleStyle = element.currentStyle; //IE only
        if (!visibleStyle)
        {
            if (document.defaultView && document.defaultView.getComputedStyle) //Firefox only
                visibleStyle = document.defaultView.getComputedStyle(element, "");
            else
                visibleStyle = element.style;
        }

        return visibleStyle;
    },

    this.getComputedStyle = function(element, styleName)
    {
        // Retrieve the cascaded direction attribute/style.
        // The currentStyle property is supported by IE.
        // Other browsers (Firefox, Safari) must use the
        // getComputedStyle method.
        if (element.currentStyle != null)
        {
            // converts for ex. border-left-width in borderLeftWidth
            styleName = styleName.replace(/-\D/gi, function(s) { return s.charAt(s.length - 1).toUpperCase(); });
            return element.currentStyle[styleName];
        }
        else if (window.getComputedStyle != null)
        {
            var cs = window.getComputedStyle(element, null);
            return cs.getPropertyValue(styleName);
        }
        return null;
    },

    this.getPxPerInch = function()
    {
        if (!this.DPI)
        {
            this.DPI = Microsoft_ReportingServices_HTMLRenderer_PxPerInch();
        }
        return this.DPI;
    },

    this.convertToPx = function(value)
    {
        if (!value)
            return 0;
        var lowerValue = value.toString().toLowerCase();
        if (lowerValue.indexOf("pt") > -1)
        {
            return Math.ceil(parseInt(value) / 72 * this.getPxPerInch());
        }
        else if (lowerValue.indexOf("px") > -1)
        {
            return parseInt(value);
        }
        return 0;
    },

    this.windowRect = function()
    {
        var docElementWidth = document.documentElement && document.documentElement.clientWidth ? document.documentElement : document.body;
        var docElementScroll = document.documentElement && document.documentElement.scrollLeft ? document.documentElement : document.body;

        var windowWidth = window.innerWidth != null ? window.innerWidth : docElementWidth ? docElementWidth.clientWidth : 0;
        var windowHeight = window.innerHeight != null ? window.innerHeight : docElementWidth ? docElementWidth.clientHeight : 0;
        var windowLeft = typeof (window.pageXOffset) != 'undefined' ? window.pageXOffset : docElementScroll ? docElementScroll.scrollLeft : 0;
        var windowTop = typeof (window.pageYOffset) != 'undefined' ? window.pageYOffset : docElementScroll ? docElementScroll.scrollTop : 0;

        var windowScrollWidth = docElementScroll ? docElementScroll.scrollWidth : 0;
        var windowScrollHeight = docElementScroll ? docElementScroll.scrollHeight : 0;

        var isVScroll = Sys.Browser.agent == Sys.Browser.InternetExplorer ? false : windowHeight < windowScrollHeight;
        var isHScroll = Sys.Browser.agent == Sys.Browser.InternetExplorer ? false : windowWidth < windowScrollWidth;

        return {
            top: windowTop,
            left: windowLeft,
            bottom: windowTop + windowHeight - (isHScroll ? 18 : 0),
            right: windowLeft + windowWidth - (isVScroll ? 18 : 0),
            width: windowWidth,
            height: windowHeight,
            scrollWidth: Math.max(windowWidth, windowScrollWidth),
            scrollHeight: Math.max(windowHeight, windowScrollHeight),
            clientWidth: windowWidth - (isVScroll ? 18 : 0),
            clientHeight: windowHeight - (isHScroll ? 18 : 0)
        };
    },

    this.isQuirksMode = function()
    {
        // document.compatMode dom property now works for latest versions of safari/FF/IE.
        return document.compatMode == "BackCompat";
    },

    this.isSafari = function()
    {
        return Sys.Browser.agent == Sys.Browser.Safari;
    },

    this.isIEQuirksMode = function()
    {
        return Sys.Browser.agent == Sys.Browser.InternetExplorer && this.isQuirksMode();
    },

    this.isPreIE8StandardsMode = function()
    {
        if (Sys.Browser.agent != Sys.Browser.InternetExplorer)
            return false;

        if (Sys.Browser.version <= 7)
            return document.compatMode == "CSS1Compat";
        else
            return Sys.Browser.documentMode == 7; // See isIE8StandardMode for definition of documentMode
    },

    this.isIE8StandardsMode = function()
    {
        // documentMode is
        // 5 for quirks mode
        // 7 for IE7 standards mode
        // 8 for IE8 standards mode
        return Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.version >= 8 && Sys.Browser.documentMode == 8;
    },

    this.isIE8StandardsModeOrLater = function()
    {
        return Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.documentMode && Sys.Browser.documentMode >= 8;
    },

    this.isIE10OrLower = function ()
    {
        // Starting IE11, the MSIE term isn't included in the user agent string.
        return !!navigator.userAgent.match(/MSIE/)
    }

    this.getNewLineDelimiter = function()
    {
        if (!this.m_newLineDelimiter)
        {
            // Some browsers use \n as the new line delimiter, some use \r\n.  Assigning \n to the text
            // area will cause the browser to convert it to \r\n if needed.
            var textArea = document.createElement("textarea");
            textArea.value = "\n";
            this.m_newLineDelimiter = textArea.value;
        }

        return this.m_newLineDelimiter;
    },

    this.getDocument = function(element)
    {
        if (element)
            return element.ownerDocument || element.document || element;
        return document;
    },

    this.getWindow = function(element)
    {
        var doc = this.getDocument(element);
        return doc.defaultView || doc.parentWindow;
    },

    this.setButtonStyle = function(element, style, cursor)
    {
        if (style.CssClass)
        {
            element.className = style.CssClass;
        }
        else
        {
            element.style.border = style.Border;
            if (Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.version < 7)
            {
                if (element.style.borderColor.toLowerCase() == "transparent")
                {
                    element.style.padding = element.style.borderWidth;
                    element.style.border = "";
                }
                else
                    element.style.padding = "0px";
            }
            element.style.backgroundColor = style.Color;
            element.style.cursor = cursor;
        }
    },

    this.SetElementVisibility = function(element, makeVisible)
    {
        if (makeVisible)
            element.style.display = "";
        else
            element.style.display = "none";

    },

    this.documentOffset = function(element)
    {
        /// <summary>
        /// Returns the offset in pixels of the given element from the body
        /// </summary>

        if (!element || !element.ownerDocument)
        {
            throw Error.argumentNull("element");
        }

        var box = element.getBoundingClientRect();
        var doc = element.ownerDocument;
        var body = doc.body;
        var docElem = doc.documentElement;

        // docElem.clientTop = non IE, body.clientTop = IE
        var clientTop = docElem.clientTop || body.clientTop || 0;
        var clientLeft = docElem.clientLeft || body.clientLeft || 0;

        // pageX/YOffset = FF, safari   docElem.scrollTop/Left = IE standards   body.scrollTop/Left = IE quirks
        var top = box.top + (self.pageYOffset || docElem.scrollTop || body.scrollTop || 0) - clientTop;
        var left = box.left + (self.pageXOffset || docElem.scrollLeft || body.scrollLeft || 0) - clientLeft;

        return { top: top, left: left };
    },

    this.getBounds = function(element)
    {
        /// <summary>
        /// Returns the overall dimensions of an element: top and left offsets from the body,
        /// as well as the width and height of the element
        /// </summary>

        if (element == null)
        {
            throw Error.argumentNull("element");
        }

        var width = Math.max(this.getFloat(this.getComputedStyle(element, "width")), element.clientWidth);
        width += this.getFloat(element.style.marginLeft) + this.getFloat(element.style.marginRight);
        width += this.getFloat(element.style.borderLeftWidth) / 2.0 + this.getFloat(element.style.borderRightWidth) / 2.0;

        var height = Math.max(this.getFloat(this.getComputedStyle(element, "height")), element.clientHeight);
        height += this.getFloat(element.style.marginTop) + this.getFloat(element.style.marginBottom);
        height += this.getFloat(element.style.borderBottomWidth) / 2.0 + this.getFloat(element.style.borderTopWidth) / 2.0;

        var offset = this.documentOffset(element);

        return { left: offset.left, top: offset.top, width: Math.round(width), height: Math.round(height), right: offset.left + Math.round(width), bottom: offset.top + Math.round(height) };
    },

    this.getFloat = function(value)
    {
        /// <summary>
        /// Attempts to parse the incoming value into a float.
        /// If it can't, returns zero.
        /// </summary>

        var parsed = parseFloat(value);

        if (isNaN(parsed))
        {
            return 0;
        }

        return parsed;
    },

    this.getInt = function(value)
    {
        /// <summary>
        /// Attempts to parse the incoming value into an int.
        /// If it can't, returns zero.
        /// </summary>

        var parsed = parseInt(value);

        if (isNaN(parsed))
        {
            return 0;
        }

        return parsed;
    },

    // Based on Sys.UI.DomElement.getElementById, but without the array shifting and with some
    // optimizations knowing that the id is a postback target
    this.getPostBackTargetElementById = function(id, element)
    {
        if (!element)
            return document.getElementById(id);
        if (element.getElementById)
            return element.getElementById(id);

        var nodeQueue = [element];
        var frontIndex = 0;

        while (frontIndex < nodeQueue.length)
        {
            node = nodeQueue[frontIndex++];
            if (node.id == id)
            {
                return node;
            }

            // The postback target can't be an option in a select, so no need to enumerate them all
            if (node.tagName != "SELECT")
            {
                var childNodes = node.childNodes;
                for (i = 0; i < childNodes.length; i++)
                {
                    node = childNodes[i];
                    if (node.nodeType == 1)
                    {
                        nodeQueue.push(node);
                    }
                }
            }
        }
        return null;
    }
}

var _$RVCommon = new Microsoft.Reporting.WebFormsClient._Common();
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._HoverImage = function (element)
{
    Microsoft.Reporting.WebFormsClient._HoverImage.initializeBase(this, [element]);

    this.OnClickScript = null;

    this.m_reportViewer = null;
    this.IsRtlVisible = false;
    this.LTRImageID = null;
    this.RTLImageID = null;
}

Microsoft.Reporting.WebFormsClient._HoverImage.prototype =
{
    initialize: function ()
    {
        Microsoft.Reporting.WebFormsClient._HoverImage.callBaseMethod(this, "initialize");
        $addHandlers(this.get_element(),
            { "mouseover": this.OnMouseOver,
                "mouseout": this.OnMouseOut,
                "click": this.OnClick },
            this);

        this.OnMouseOut(null);

        this.SetImageButton();
    },

    dispose: function ()
    {
        $clearHandlers(this.get_element());
        this.m_reportViewer = null;

        Microsoft.Reporting.WebFormsClient._HoverImage.callBaseMethod(this, "dispose");
    },

    set_NormalStyles: function (value) { this._normalStyles = value; },
    get_NormalStyles: function () { return this._normalStyles; },

    set_HoverStyles: function (value) { this._hoverStyles = value; },
    get_HoverStyles: function () { return this._hoverStyles; },

    set_ReportViewer: function (value)
    {
        this.m_reportViewer = value;
    },

    OnMouseOver: function (e)
    {
        if (this.OnClickScript == null)
            return;
        if (!this.IsButtonDisabled())
        {
            _$RVCommon.setButtonStyle(this.get_element(), this._hoverStyles, "pointer");
        }
    },

    OnMouseOut: function (e)
    {
        if (!this.IsButtonDisabled())
        {
            _$RVCommon.setButtonStyle(this.get_element(), this._normalStyles, "default");
        }
    },

    OnClick: function (e)
    {
        if (!this.IsButtonDisabled())
        {
            if (this.OnClickScript != null)
                this.OnClickScript();
        }

        e.preventDefault();
    },

    SetImageButton: function ()
    {
        if (this.m_reportViewer != null)
        {
            var direction = this.m_reportViewer._get_direction();

            var needsRtlVisible = direction === "rtl";

            if (needsRtlVisible != this.IsRtlVisible)
            {
                var ltrImage = document.getElementById(this.LTRImageID);
                var rtlImage = document.getElementById(this.RTLImageID);

                if (needsRtlVisible)
                {
                    rtlImage.style.display = "";
                    ltrImage.style.display = "none";
                }
                else
                {
                    rtlImage.style.display = "none";
                    ltrImage.style.display = "";
                }

                this.IsRtlVisible = needsRtlVisible;
            }
        }
    },

    IsButtonDisabled: function ()
    {
        var button = this.get_element();
        var buttonDisabledValue;

        // Button is table element. The HoverImage renders Enabled=false as disabled="disabled" attribute.
        // Some of the browsers interpred this as boolean disabled property, but is not in the standard for table element. 
        if (typeof (button.disabled) != "undefined")
        {
            return button.disabled;
        }

        var buttonDisabledValue;
        if (button.attributes && (typeof (button.attributes["disabled"]) != "undefined"))
            buttonDisabledValue = button.attributes["disabled"].nodeValue;

        if (buttonDisabledValue == "disabled")
            return true;
        else
            return false;
    }
}

Microsoft.Reporting.WebFormsClient._HoverImage.registerClass("Microsoft.Reporting.WebFormsClient._HoverImage", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._InternalReportViewer = function(element)
{
    Microsoft.Reporting.WebFormsClient._InternalReportViewer.initializeBase(this, [element]);

    this.ReportViewerId = null;
    this.ReportAreaId = null;
    this.DocMapAreaId = null;
    this.FixedTableId = null;

    this.ActionTypeId = null;
    this.ActionParamId = null;
    this.HasSizingRow = true;

    this.BaseHeight = null;
    this.BaseWidth = null;

    this.PromptAreaRowId = null;
    this.PromptSplitterId = null;
    this.DocMapSplitterId = null;
    this.DirectionCacheId = null;
    this.DocMapHeaderOverflowDivId = null;
    this.BrowserModeId = null;

    this.UnableToLoadPrintMessage = null;

    this.PostBackToClientScript = null;

    this.ExportUrlBase = null;
    this.m_printInfo = null;

    this.m_OnAppLoadDelegate = Function.createDelegate(this, this.OnAppLoad);
    this.m_OnReportAreaContentChangedDelegate = Function.createDelegate(this, this.OnReportAreaContentChanged);
    this.m_OnAsyncPostBackStartedDelegate = Function.createDelegate(this, this.OnAsyncPostBackStarted);
    this.m_OnAsyncPostBackEndedDelegate = Function.createDelegate(this, this.OnAsyncPostBackEnded);
    this.m_OnReportAreaScrollPositionChangedDelegate = Function.createDelegate(this, this.OnReportAreaScrollPositionChanged);
    this.m_OnReportAreaNewContentVisibleDelegate = Function.createDelegate(this, this.OnReportAreaNewContentVisible);
    this.m_OnWindowResizeDelegate = Function.createDelegate(this, this.OnWindowResize);
    
    //This is the event supported on android and iOS browsers.  However, the actual behavior is inconsistent across devices, so subscribe to both resize and orientationchange.
    this.m_OnOrientationChangeDelegate = Function.createDelegate(this, this.OnOrientationChange);    
    this.m_PromptSplitterCollapsingDelegate = Function.createDelegate(this, this.OnPromptSplitterCollapsing);
    this.m_DocMapSplitterCollapsingDelegate = Function.createDelegate(this, this.OnDocMapSplitterCollapsing);
    this.m_DocMapSplitterResizingDelegate = Function.createDelegate(this, this.OnDocMapSplitterResizing);

    this.m_onAppLoadCalled = false;
    this.m_useResizeScript = false;
    this.m_reportViewer = null;
    this.m_isLoading = true;
    this.m_toolBarUpdate = {};
    this.m_reportAreaContentChanged = false;

    this.m_previousWindowHeight = -1;
    this.m_previousWindowWidth = -1;
}

Microsoft.Reporting.WebFormsClient._InternalReportViewer.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._InternalReportViewer.callBaseMethod(this, "initialize");
        Sys.Application.add_load(this.m_OnAppLoadDelegate);
    },

    dispose: function()
    {
        Microsoft.Reporting.WebFormsClient._InternalReportViewer.callBaseMethod(this, "dispose");

        if (this.m_OnAppLoadDelegate != null)
        {
            Sys.Application.remove_load(this.m_OnAppLoadDelegate);
            delete this.m_OnAppLoadDelegate;
            this.m_OnAppLoadDelegate = null;
        }

        if (this.m_OnReportAreaContentChangedDelegate != null)
        {
            delete this.m_OnReportAreaContentChangedDelegate;
            this.m_OnReportAreaContentChangedDelegate = null;
        }

        if (this.m_OnReportAreaNewContentVisibleDelegate != null)
        {
            delete this.m_OnReportAreaNewContentVisibleDelegate;
            this.m_OnReportAreaNewContentVisibleDelegate = null;
        }

        if (this.m_OnAsyncPostBackStartedDelegate != null)
        {
            var pageRequestManager = this.GetPageRequestManager();
            if (pageRequestManager != null)
            {
                pageRequestManager.remove_beginRequest(this.m_OnAsyncPostBackStartedDelegate);
                pageRequestManager.remove_endRequest(this.m_OnAsyncPostBackEndedDelegate);
            }

            delete this.m_OnAsyncPostBackStartedDelegate;
            this.m_OnAsyncPostBackStartedDelegate = null;

            delete this.m_OnAsyncPostBackEndedDelegate;
            this.m_OnAsyncPostBackEndedDelegate = null;
        }

        if (this.m_OnReportAreaScrollPositionChangedDelegate != null)
        {
            delete this.m_OnReportAreaScrollPositionChangedDelegate;
            this.m_OnReportAreaScrollPositionChangedDelegate = null;
        }

        if (this.m_OnWindowResizeDelegate != null)
        {
            if (this.m_useResizeScript)
                $removeHandler(window, "resize", this.m_OnWindowResizeDelegate);

            delete this.m_OnWindowResizeDelegate;
            this.m_OnWindowResizeDelegate = null;
        }

        if (this.m_OnOrientationChangeDelegate != null)
        {
            $removeHandler(window, "orientationchange", this.m_OnOrientationChangeDelegate);
            delete this.m_OnOrientationChangeDelegate;
            this.m_OnOrientationChangeDelegate = null;
        }

        if (this._promptSplitter)
            this._promptSplitter.remove_collapsing(this.m_PromptSplitterCollapsingDelegate);
        delete this.m_PromptSplitterCollapsingDelegate;
        this.m_PromptSplitterCollapsingDelegate = null;

        if (this._docMapSplitter)
        {
            this._docMapSplitter.remove_collapsing(this.m_DocMapSplitterCollapsingDelegate);
            this._docMapSplitter.remove_resizing(this.m_DocMapSplitterResizingDelegate);
        }
        delete this.m_DocMapSplitterCollapsingDelegate;
        this.m_DocMapSplitterCollapsingDelegate = null;
        delete this.m_DocMapSplitterResizingDelegate;
        this.m_DocMapSplitterResizingDelegate = null;

        if (this._docMapCells != null)
        {
            delete this._docMapCells;
            this._docMapCells = null;
        }
    },

    ResetWindowSizeCache: function()
    {
        // this is to explicitly force HasWindowChangedSize
        // to return true, thus forcing the resize code to run in IE

        this.m_previousWindowHeight = -1;
        this.m_previousWindowWidth = -1;
    },

    // Custom accessor for complex object type (array)
    set_PrintInfo: function(value) { this.m_printInfo = value; },
    get_PrintInfo: function() { return this.m_printInfo; },

    OnAppLoad: function()
    {
        if (!this.m_onAppLoadCalled)
        {
            var reportAreaElement = $get(this.ReportAreaId);
            var reportAreaControl = reportAreaElement.control;
            reportAreaControl.add_contentChanged(this.m_OnReportAreaContentChangedDelegate);
            reportAreaControl.add_propertyChanged(this.m_OnReportAreaScrollPositionChangedDelegate);
            reportAreaControl.add_newContentVisible(this.m_OnReportAreaNewContentVisibleDelegate);

            var pageRequestManager = this.GetPageRequestManager();
            if (pageRequestManager != null)
            {
                pageRequestManager.add_beginRequest(this.m_OnAsyncPostBackStartedDelegate);
                pageRequestManager.add_endRequest(this.m_OnAsyncPostBackEndedDelegate);
            }

            this.m_useResizeScript = !_$RVCommon.isIEQuirksMode() && parseFloat(this.BaseHeight) != 0 && this.HasSizingRow;
            if (this.m_useResizeScript) 
            {
                $addHandler(window, "resize", this.m_OnWindowResizeDelegate);
            }

            $addHandler(window, "orientationchange", this.m_OnOrientationChangeDelegate);
            this.UpdateBrowserMode();
            this.m_onAppLoadCalled = true;
        }

        if (!this._promptSplitter)
        {
            this._promptSplitter = $get(this.PromptSplitterId).control;
            this._promptSplitter.add_collapsing(this.m_PromptSplitterCollapsingDelegate);
        }

        if (!this._docMapSplitter)
        {
            this._docMapSplitter = $get(this.DocMapSplitterId).control;
            this._docMapSplitter.add_collapsing(this.m_DocMapSplitterCollapsingDelegate);
            this._docMapSplitter.add_resizing(this.m_DocMapSplitterResizingDelegate);
        }

        if (this._docMapCells != null)
        {
            delete this._docMapCells;
            this._docMapCells = null;
        }

        this._UpdateDocMapAreaUIVisibility();

        this.ResizeViewerReportUsingContainingElement(false);

        // we want IE to call our resize code once again after the page has fully loaded
        this.ResetWindowSizeCache();

        this.HideSizingRow();
    },

    HideSizingRow: function()
    {
        // the row can only be hidden for IE quirks mode
        // Generally it can be hidden in pre IE8 standards mode, but this fails in the webpart
        
        // VSTS 2442076: When running within an IFRAME in IE8 or later, the page hosting the IFRAME affects
        // the mode detection logic.  isIEQuirksMode and isIE8StandardsModeOrLater will both return true.
        // However, we do not want to hide the sizing row to accomodate for an IE security fix that will
        // result in the report viewer area being shrunk to one third of the available area.
        if (this.HasSizingRow && _$RVCommon.isIEQuirksMode() && !_$RVCommon.isIE8StandardsModeOrLater())
        {
            var fixedTable = $get(this.FixedTableId);
            var sizingRow = fixedTable.rows.item(0);
            sizingRow.style.display = "none";
        }
    },

    OnReportAreaContentChanged: function(sender, eventArgs)
    {
        this.m_toolBarUpdate = eventArgs.ToolBarUpdate;
        this.m_reportAreaContentChanged = true;

        // If the report loaded so quickly that the async request hasn't
        // finished yet, wait for it to complete before enabling things.
        var pageRequestManager = this.GetPageRequestManager();
        if (pageRequestManager == null || !pageRequestManager.get_isInAsyncPostBack())
            this.EnableDisableInput(true);
    },

    OnReportAreaNewContentVisible: function(sender, eventArgs)
    {
        if (this.get_reportAreaContentType() == Microsoft.Reporting.WebFormsClient.ReportAreaContent.ReportPage)
        {
            // bring the docmap into view now that the report is ready
            var docMap = $get(this.DocMapAreaId);
            _$RVCommon.SetElementVisibility(docMap, true);
            this._UpdateDocMapAreaUIVisibility();
        }

        var reportAreaNewContentVisibleHandler = this.get_events().getHandler("reportAreaNewContentVisible");
        if (reportAreaNewContentVisibleHandler)
            reportAreaNewContentVisibleHandler(this, eventArgs);
    },

    OnWindowResize: function()
    {
        this.ResizeViewerReportUsingContainingElement(false);
    },

    OnOrientationChange: function()
    {
        this.ResizeViewerReportUsingContainingElement(false);
    },
    
    HasWindowChangedSize: function()
    {
        // this method is only relevant to IE
        if (Sys.Browser.agent != Sys.Browser.InternetExplorer)
        {
            // "true" esentially means "go ahead and run the resize code"
            return true;
        }

        var width = document.body.clientWidth;
        var height = document.body.clientHeight;

        var changed = width !== this.m_previousWindowWidth || height !== this.m_previousWindowHeight;

        this.m_previousWindowHeight = height;
        this.m_previousWindowWidth = width;

        return changed;
    },

    ResetSizeToServerDefault: function()
    {
        // Reset all sizes changed by ResizeViewerReportUsingContainingElement to the way they
        // appeared before any client side manipulation.

        var reportViewer = $get(this.ReportViewerId);
        reportViewer.style.height = this.BaseHeight;

        var reportArea = $get(this.ReportAreaId);
        reportArea.parentNode.style.height = "100%";

        var visibleContainer = $get(reportArea.control.VisibleReportContentContainerId);
        visibleContainer.style.height = "100%";
        visibleContainer.style.width = "";

        this.SetLastRowHeight("100%");

        var docMapCells = this.GetDocMapCells();
        if (docMapCells.sizingElement != null)
            docMapCells.sizingElement.style.height = "100%";
    },

    ResizeViewerReportUsingContainingElement: function(forceRecalculate)
    {
        var reportViewer = $get(this.ReportViewerId);
        var reportArea = $get(this.ReportAreaId);

        // It is possible for the window resize event to fire before everything is created.
        if (reportArea.control == null)
            return;

        // in IE, we only want to execute this code if the window has truly changed
        // size in most cases. That is what the HasWindowChangedSize checks for.
        // Otherwise IE will call the resize handler often, and our handler will cause
        // them to fire resize even more, leading to crashing the browser
        if (!forceRecalculate && (!this.m_useResizeScript || !this.HasWindowChangedSize()))
            return;

        var isHeightPercentage = false;

        if (this.BaseHeight.indexOf('%') >= 0)
        {
            isHeightPercentage = true;
        }

        var reportViewerHeight = -1;
        var reportAreaHeight = -1;

        if (isHeightPercentage)
        {
            var actualHeight = this.GetReportViewerHeight();
            reportViewerHeight = Math.round(((actualHeight) / 100) * parseFloat(this.BaseHeight));
        }
        else
        {
            reportViewerHeight = _$RVCommon.convertToPx(this.BaseHeight);
        }

        var toolbarHeight = this.GetFixedHeight();
        reportAreaHeight = reportViewerHeight - toolbarHeight;


        if ((reportViewerHeight == 0 && isHeightPercentage) ||
            reportViewerHeight < 0 ||
            reportAreaHeight < 0 ||
            (reportViewerHeight < reportAreaHeight))
        {
            // At least make the doc map the same height as the report area
            this.SetDocMapAreaHeight(reportArea.offsetHeight);
        }
        else
        {
            reportViewer.style.height = reportViewerHeight + "px";
            reportArea.parentNode.style.height = reportAreaHeight + "px";

            var visibleContainer = $get(reportArea.control.VisibleReportContentContainerId);
            if (visibleContainer && visibleContainer.style)
            {
                var visibleStyle = _$RVCommon.getStyleForElement(visibleContainer);

                //Take into consideration the borders and remove them from the width.  IE Standards mode, Firefox, and Safari need this
                var sumofborderHeight = _$RVCommon.convertToPx(visibleStyle.borderTopWidth)
                    + _$RVCommon.convertToPx(visibleStyle.borderBottomWidth);
                var sumofborderWidth = _$RVCommon.convertToPx(visibleStyle.borderLeftWidth)
                    + _$RVCommon.convertToPx(visibleStyle.borderRightWidth);

                if (sumofborderHeight > 0 || sumofborderWidth > 0)
                {
                    //Do not make the sizes less than the minimum of the data
                    var reportDivId = reportArea.control.GetReportPage().ReportDivId; //Use the oReportDiv/TABLE to calc the minimum sizing
                    var minHeight = reportDivId ? $get(reportDivId).childNodes[0].clientHeight : 0;
                    var minWidth = reportDivId ? $get(reportDivId).childNodes[0].clientWidth : 0;

                    //IE calculates the sizing to need scrollbars if the content is larger than the outer size.
                    //This makes the content start as zero.
                    visibleContainer.style.height = 0;
                    visibleContainer.style.width = 0;

                    var targetHeight = 0;
                    var targetWidth = 0;

                    //Make sure the visiblecontainer size is at least the size of the report content
                    if (sumofborderHeight > 0)
                        targetHeight = Math.max(reportArea.clientHeight - sumofborderHeight, minHeight);

                    if (sumofborderWidth > 0)
                        targetWidth = Math.max(reportArea.clientWidth - sumofborderWidth, minWidth);

                    if (targetHeight > 0)
                        visibleContainer.style.height = targetHeight + "px";
                    if (targetWidth > 0)
                        visibleContainer.style.width = targetWidth + "px";
                }
            }

            this.SetLastRowHeight(reportAreaHeight + "px");

            // Finally set the DocMapArea height.
            this.SetDocMapAreaHeight(reportAreaHeight);
        }

        // IE 7 standards mode - when the viewer is in an inline element and there is a doc map, IE
        // collapses the width of the entire viewer to the width of the splitter (the fixed width column).
        // To calculate the correct width in this case, hide the splitter and use the width that IE
        // assigns when only percentage width columns are visible.
        if (_$RVCommon.isPreIE8StandardsMode() &&   // IE 7 standards mode
            this.BaseWidth.indexOf('%') > 0 &&      // Percentage width
            this.HasSizingRow)                      // Not SizeToReportContent
        {
            // Hide the doc map
            this._UpdateDocMapAreaUIVisibility(true);

            // Revert viewer to its original value
            reportViewer.style.width = this.BaseWidth;

            // Calculate parent width and Set width on viewer
            reportViewer.style.width = reportViewer.clientWidth + "px";

            // Restore doc map
            this._UpdateDocMapAreaUIVisibility();
        }

        this._UpdateDocMapAreaUIWidth(Number.NaN);
    },

    SetLastRowHeight: function(height)
    {
        var result = null;
        var lastRow = $get(this.FixedTableId).rows.item(this.HasSizingRow ? 4 : 3);
        for (var cellIndex = 0; cellIndex < lastRow.cells.length; cellIndex++)
        {
            if (!result)
                result = lastRow.cells.item(cellIndex).style.height;
            lastRow.cells.item(cellIndex).style.height = height;
        }
        return result;
    },

    GetReportViewerHeight: function()
    {
        var reportArea = $get(this.ReportAreaId);
        var top = reportArea.scrollTop;
        var left = reportArea.scrollLeft;
        var docMap = this.GetDocMapCells();
        var docMapTop = 0;
        var docMapLeft = 0;
        if (docMap != null && docMap.docMapContainer != null)
        {
            docMapTop = docMap.docMapContainer.scrollTop;
            docMapLeft = docMap.docMapContainer.scrollLeft;
        }

        var reportViewer = $get(this.ReportViewerId);
        var height = 0;

        // Remember the current display style for the viewer
        var viewerDisplayStyle = reportViewer.style.display;
        var originalHeight = reportViewer.style.height;

        // Hide the viewer so it does not alter the dimensions of its parent.
        reportViewer.style.display = "none";

        // Set the viewer height back to its original value, otherwise fixed pixel height
        // will prevent the collapse we need for recalculation in non-IE browsers.
        reportViewer.style.height = this.BaseHeight;

        // The extra parentNode here is the update panel that encapsulates the reportViewer Control.
        height = reportViewer.parentNode.parentNode.clientHeight;

        // Make the viewer visible again.
        reportViewer.style.display = viewerDisplayStyle;
        reportViewer.style.height = originalHeight;

        if (top > 0 || left > 0)
        {
            // With the display = 'none' above, Firefox resets the scroll position.  Scroll back to the previous point.
            var currentTop = reportArea.scrollTop;
            var currentLeft = reportArea.scrollLeft;
            if (top != currentTop)
                reportArea.scrollTop = top;
            if (left != currentLeft)
                reportArea.scrollLeft = left;
        }

        if (docMapTop > 0 || docMapLeft > 0)
        {
            var currentTop = docMap.docMapContainer.scrollTop;
            var currentLeft = docMap.docMapContainer.scrollLeft;
            if (docMapTop != currentTop)
                docMap.docMapContainer.scrollTop = docMapTop;
            if (docMapLeft != currentLeft)
                docMap.docMapContainer.scrollLeft = docMapLeft;
        }

        return height;
    },

    GetFixedHeight: function()
    {
        var height = 0;

        var fixedTable = $get(this.FixedTableId);
        if (fixedTable != null)
        {
            // set last row height 100% so can push the upper rows up;
            // Preserve scroll position - this method should not alter the display
            var oldScrollPos = this.get_reportAreaScrollPosition();
            var oldHeight = this.SetLastRowHeight("100%")

            var rows = fixedTable.rows;

            // Get the offsetHeight of all the rows except the last one as that is the reportArea.
            // Accessing hidden offsetHeight row causes resize event in IE8 compat.
            for (var i = 0; i < (rows.length - 1); i++)
            {
                if (rows[i].style.display != "none")
                    height += rows[i].offsetHeight;
            }

            this.SetLastRowHeight(oldHeight);
            this.set_reportAreaScrollPosition(oldScrollPos);
        }

        return height;
    },

    OnAsyncPostBackStarted: function()
    {
        this.EnableDisableInput(false);
    },

    OnAsyncPostBackEnded: function()
    {
        var reportAreaElement = $get(this.ReportAreaId);
        var reportAreaControl = reportAreaElement.control;

        // Async postback disabled the toolbar.  If no new page was loaded (or
        // loading completed before the request ended), no report area load event
        // will follow, so set the toolbar back to enabled here.
        if (!reportAreaControl.IsLoading())
            this.EnableDisableInput(true);
    },

    get_isLoading: function()
    {
        return this.m_isLoading;
    },

    get_reportAreaScrollPosition: function()
    {
        var reportAreaElement = $get(this.ReportAreaId);
        var reportAreaControl = reportAreaElement.control;
        if (reportAreaControl != null)
            return reportAreaControl.get_scrollPosition();
        else
            return new Sys.UI.Point(0, 0);
    },

    set_reportAreaScrollPosition: function(scrollPoint)
    {
        var reportAreaElement = $get(this.ReportAreaId);
        var reportAreaControl = reportAreaElement.control;
        if (reportAreaControl != null)
            return reportAreaControl.set_scrollPosition(scrollPoint);
    },

    OnReportAreaScrollPositionChanged: function(sender, e)
    {
        if (e.get_propertyName() == "scrollPosition")
            this.raisePropertyChanged("reportAreaScrollPosition");
    },

    EnableDisableInput: function(shouldEnable)
    {
        if (this.m_isLoading == shouldEnable)
        {
            this.m_isLoading = !shouldEnable;
            this.raisePropertyChanged("isLoading");

            // Fire the report area content changed event
            if (this.m_reportAreaContentChanged)
            {
                this.raisePropertyChanged("reportAreaContentType");
                this.m_reportAreaContentChanged = false;
            }
        }

        // Enable/Disable various viewer regions.  If enabling and about to trigger a postback
        // (which would just disable things again), skip the enable.
        if (!shouldEnable || !Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected)
        {
            var reportAreaElement = $get(this.ReportAreaId);
            if (reportAreaElement && reportAreaElement.control)
                reportAreaElement.control.EnableDisableInput(shouldEnable);
            this._promptSplitter.SetActive(shouldEnable);
            this._docMapSplitter.SetActive(shouldEnable);

            var docMap = $get(this.DocMapAreaId).control;
            if (docMap)
                docMap.SetActive(shouldEnable);
        }

        this.ResizeViewerReportUsingContainingElement(false);
    },

    add_reportContentLoaded: function(handler)
    {
        var reportAreaElement = $get(this.ReportAreaId);
        var reportAreaControl = reportAreaElement.control;
        reportAreaControl.add_reportContentLoaded(handler);
    },

    remove_reportContentLoaded: function(handler)
    {
        var reportAreaElement = $get(this.ReportAreaId);
        var reportAreaControl = reportAreaElement.control;
        reportAreaControl.remove_reportContentLoaded(handler);
    },

    add_reportAreaNewContentVisible: function(handler)
    {
        this.get_events().addHandler("reportAreaNewContentVisible", handler);
    },

    remove_reportAreaNewContentVisible: function(handler)
    {
        this.get_events().removeHandler("reportAreaNewContentVisible", handler);
    },

    ExportReport: function(format)
    {
        if (this.ExportUrlBase == null)
            return false;

        window.open(this.ExportUrlBase + encodeURIComponent(format), "_blank");
        return true;
    },

    // alreadyLoaded:
    //   - true if we know that the print object was already loaded and we're reusing it
    //   - false if we just got notified that the print object was loaded
    //   If the value is true, the check whether the print object is ready is omitted and we fail if it's not available,
    //   this allows reporting user dialog errors when the user clicks on the Print button for the second
    //   when it already failed for the first time (disabled ActiveX, Modern IE, ...).
    Print: function(alreadyLoaded)
    {
        var printInfo = this.m_printInfo;
        if (printInfo == null)
            return false;

        var printObjectId = this.ReportViewerId + "_PrintObj";
        var printObj = $get(printObjectId);

        if (printObj && (alreadyLoaded || printObj.readyState == 4 /* Complete */))
        {
            if (typeof printObj.Print == "undefined")
            {
                alert(this.UnableToLoadPrintMessage);
                return false;
            }

            printObj.MarginLeft = printInfo.MarginLeft;
            printObj.MarginTop = printInfo.MarginTop;
            printObj.MarginRight = printInfo.MarginRight;
            printObj.MarginBottom = printInfo.MarginBottom;

            printObj.PageHeight = printInfo.PageHeight;
            printObj.PageWidth = printInfo.PageWidth;

            printObj.Culture = printInfo.Culture;
            printObj.UICulture = printInfo.UICulture;

            printObj.UseSingleRequest = printInfo.UseSingleRequest;
            printObj.UseEmfPlus = true;

            printObj.Print(printInfo.PrintRequestPath, printInfo.PrintRequestQuery, printInfo.ReportDisplayName);
            return true;
        }
        return false;
    },

    PrintDialog: function()
    {
        var printInfo = this.m_printInfo;
        if (printInfo == null)
            return false;

        var printObjectId = this.ReportViewerId + "_PrintObj";

        // Load the print control if it hasn't happened already
        var printObj = $get(printObjectId);
        if (printObj == null)
		{
            try
            {
                printObj = document.createElement("OBJECT");
                printObj.id = printObjectId;
                printObj.style.display = "none";
                printObj.ReportViewer = this;
                // Codebase must be before classid in order to download the control
                printObj.codeBase = printInfo.CabUrl;
                printObj.setAttribute("VIEWASTEXT", "");
                var reportViewer = $get(this.ReportViewerId);
                var printFunction = function() { this.ReportViewer.Print(false); };

                if (_$RVCommon.isIE10OrLower()) {
                    printObj.onreadystatechange = printFunction;
                    //Element must be added before printing occurs as the event can fire before this is added to the window.
                    reportViewer.appendChild(printObj);
                    printObj.classid = "CLSID:" + printInfo.CabClsid;
                } else {
                    // printObj.onreadystatechange doesn't work on IE11 and beyond. The following is supported.
                    printObj.addEventListener("readystatechange", printFunction);
                    // Starting IE11, activex controls embedded in object elements aren't loaded if the classID isn't set before adding them to the tree.
                    // If this behavior would be in previous versions as well, the onreadystatechange event wouldn't fire.
                    // That's why the special behavior only for IE11.
                    printObj.classid = "CLSID:" + printInfo.CabClsid;
                    reportViewer.appendChild(printObj);
                }

                return true;
            }
            catch (exception)
            {
                alert(this.UnableToLoadPrintMessage);
                return false;
            }
        }
        else
        {
            return this.Print(true);
        }
    },

    SetPromptAreaVisibility: function(makeVisible)
    {
        var parametersRow = $get(this.PromptAreaRowId);
        if (parametersRow == null)
            return;
        _$RVCommon.SetElementVisibility(parametersRow, makeVisible);
        this._promptSplitter._setCollapsed(!makeVisible);
        this.raisePropertyChanged("promptAreaCollapsed");
        this.ResizeViewerReportUsingContainingElement(true);
    },

    ArePromptsVisible: function()
    {
        return !this._promptSplitter._getCollapsed();
    },

    GetDocMapCells: function()
    {
        if (!this._docMapCells)
        {
            var fixedTable = $get(this.FixedTableId);
            this._docMapCells = {
                docMapHeadCell: this.HasSizingRow ? fixedTable.rows.item(0).cells.item(0) : null,
                splitterDocMapHeadCell: this.HasSizingRow ? fixedTable.rows.item(0).cells.item(1) : null,
                docMapCell: fixedTable.rows.item(this.HasSizingRow ? 4 : 3).cells.item(0),
                splitterDocMapCell: fixedTable.rows.item(this.HasSizingRow ? 4 : 3).cells.item(1),
                reportArea: $get(this.ReportAreaId),
                fixedTable: fixedTable,
                hasNodes: false,
                docMapTitleRow: null,
                docMapTitleCell: null,
                docMapContainerCell: null,
                docMapContainer: null,
                docMapTree: null,
                sizingElement: null
            }
            if (this.DocMapAreaId != null)
            {
                var docMapArea = $get(this.DocMapAreaId);
                if (docMapArea)
                {
                    var docMapTables = docMapArea.getElementsByTagName("table");
                    if (docMapTables.length > 0)
                    {
                        this._docMapCells.docMapTitleRow = docMapArea.getElementsByTagName("table")[0].rows.item(0);
                        this._docMapCells.docMapTitleCell = this._docMapCells.docMapTitleRow.cells.item(0);
                        this._docMapCells.docMapContainerCell = docMapArea.getElementsByTagName("table")[0].rows.item(1).cells.item(0);
                        this._docMapCells.docMapContainer = this._docMapCells.docMapContainerCell.getElementsByTagName("div")[0];
                        this._docMapCells.docMapTree = this._docMapCells.docMapContainer.getElementsByTagName("div")[0];
                        this._docMapCells.hasNodes = true;

                        if (this._docMapCells.docMapContainerCell)
                            this._docMapCells.sizingElement = this._docMapCells.docMapContainerCell.firstChild;
                    }
                }
            }
        }
        return this._docMapCells;
    },

    //Changes the visibility of the DocMap to 'makeVisible'
    //Call this when you want to 'expand/collapse' the DocMap area
    SetDocMapAreaVisibility: function(makeVisible)
    {
        var docMapCells = this.GetDocMapCells();
        if (docMapCells.hasNodes)
        {
            this._docMapSplitter._setCollapsed(!makeVisible);
            this.raisePropertyChanged("documentMapCollapsed");
        }
        this._UpdateDocMapAreaUIVisibility();
    },

    //NOT INTENDED FOR PUBLIC USE.  Call SetDocMapAreaVisibility to set the DocMap Visibility
    //This updates the HTML DOM to collapse or show the DocMapArea
    //Call this when the visiblity on the DocMap has changed so the sizing can be correctly calculated.
    //'hideEverything' == true, causes the entire DocMap UI to be 'display:none' rather than 0px wide.  
    //This is necessary for resize calculations.  IE6 and 7 standards mode need to use 0px wide drawing, so the table cells
    //in the same TR are correctly calculated (extra 1px appears on the right-hand-side)
    _UpdateDocMapAreaUIVisibility: function(hideEverything)
    {
        var docMapCells = this.GetDocMapCells();

        var makeVisible = false;
        if (!hideEverything)
            makeVisible = !this._docMapSplitter._getCollapsed() && docMapCells.hasNodes;

        var isVisible = makeVisible;
        if (!hideEverything)
        {
            // Use 0px wide to show everything rather than hiding the DocMap, if there are any doc map nodes
            makeVisible = docMapCells.hasNodes;
        }

        // Document map visibility
        if (docMapCells.docMapHeadCell)
        {
            _$RVCommon.SetElementVisibility(docMapCells.docMapHeadCell, makeVisible);
        }
        _$RVCommon.SetElementVisibility(docMapCells.docMapCell, makeVisible);

        // Splitter visibility
        if (this._docMapSplitter._getCollapsable() || makeVisible)
        {
            if (docMapCells.splitterDocMapHeadCell)
                _$RVCommon.SetElementVisibility(docMapCells.splitterDocMapHeadCell, docMapCells.hasNodes);
            _$RVCommon.SetElementVisibility(docMapCells.splitterDocMapCell, docMapCells.hasNodes);
        }

        if (!hideEverything)
        {
            var size = 0;
            if (isVisible)
            {
                //If the DocMap is visible, use the splitter size to set sizing.
                size = this._docMapSplitter._getSize();
                if (isNaN(size))
                {
                    //If not calculated, ask the UI for the current size available (won't be from a previous call)
                    size = docMapCells.docMapCell.style.width;
                }
            }
            this._UpdateDocMapAreaUIWidth(size);
        }
    },

    AreDocMapAreaVisible: function()
    {
        return !this._docMapSplitter._getCollapsed();
    },

    OnPromptSplitterCollapsing: function(sender, args)
    {
        this.SetPromptAreaVisibility(!args.get_collapse())
    },

    OnDocMapSplitterCollapsing: function(sender, args)
    {
        this.SetDocMapAreaVisibility(!args.get_collapse());
    },

    //NOT INTENDED FOR PUBLIC USE.  Call SetDocMapAreaWidth to set or resize the DocMap Width
    //This validates the 'size' is an allowable DocMapArea Width
    //Call this to verify the DocMap Width can be 'size' 
    _ValidateDocMapAreaWidth: function(size)
    {
        // If no sizing row, viewer is set to SizeToReportContent.  Shouldn't need to dynamically adjust
        // any sub areas of the viewer.
        if (!this.HasSizingRow)
            return false;

        var docMapCells = this.GetDocMapCells();
        if (docMapCells.hasNodes)
        {
            if (size >= 0)
            {
                if (docMapCells.reportArea)
                {
                    var allowedWidth = docMapCells.fixedTable.clientWidth;
                    allowedWidth -= this._docMapSplitter.get_element().parentNode.clientWidth;
                    allowedWidth -= (docMapCells.reportArea.offsetWidth - docMapCells.reportArea.clientWidth);
                    if (size > allowedWidth)
                    // cannot resize
                        return false;
                }
            }
            return true;
        }
        return false;
    },

    //Set the DocMapArea to be 'size' wide.
    //The UI will be resized to fit.
    //Call this when you need to programmatically change the DocMap Width (e.g. resizing)
    SetDocMapAreaWidth: function(size)
    {
        if (this._ValidateDocMapAreaWidth(size))
        {
            if (size >= 0)
            {
                this._docMapSplitter._setSize(size);
            }
            this._UpdateDocMapAreaUIWidth(size);
        }
    },

    //NOT INTENDED FOR PUBLIC USE.  Call SetDocMapAreaWidth to set the DocMap Width
    //This updates the HTML DOM to display the desired DocMapArea Width
    //Call this when sizings change and the DocMap needs to calculate it's width
    _UpdateDocMapAreaUIWidth: function(size)
    {
        // If no sizing row, viewer is set to SizeToReportContent.  Shouldn't need to dynamically adjust
        // any sub areas of the viewer.
        if (!this._ValidateDocMapAreaWidth(size))
            return;

        var docMapCells = this.GetDocMapCells();
        if (docMapCells.hasNodes)
        {
            var sizeStr = size + "px";
            if (isNaN(size))
                sizeStr = size;

            if (size || size == 0) //If size is not null or equals zero, calculate this.  Number.NaN fails this.
            {
                if (docMapCells.docMapHeadCell)
                {
                    docMapCells.docMapHeadCell.style.width = sizeStr;
                }
                else
                {
                    docMapCells.docMapCell.style.width = sizeStr;
                }
            }

            // Set the cell width which contains the treeview even if size is NaN.
            // Size NaN happens when there is no previous resizing (or postaback cached) by the splitter. 
            // In this case the size is determined by the server rendering.  If not set, doc map content
            // can extend beyond the splitter in some browsers.
            docMapCells.docMapContainerCell.style.width = docMapCells.docMapCell.clientWidth + "px";
            docMapCells.docMapContainer.style.width = docMapCells.docMapCell.clientWidth + "px";
            $get(this.DocMapHeaderOverflowDivId).style.width = docMapCells.docMapCell.clientWidth + "px";
        }
    },

    SetDocMapAreaHeight: function(reportAreaHeight)
    {
        if (this.DocMapAreaId != null)
        {
            var docMapCells = this.GetDocMapCells();

            // Navigate down the DOM to find the document map header and document map content. 
            // Then set the height accordingly.
            if (docMapCells.docMapContainerCell != null)
            {
                var docMapContentTd = docMapCells.docMapContainerCell;
                var docMapTitleHeight = docMapCells.docMapTitleCell.scrollHeight;

                if ((reportAreaHeight - docMapTitleHeight) > 0)
                {
                    var sizingElement = docMapCells.sizingElement;

                    if (docMapContentTd.getAttribute("HEIGHT") && !_$RVCommon.isQuirksMode())
                    {
                        //Remove the HEIGHT attribute from the TD and parent TR -- Necessary for standards mode (Safari)
                        docMapContentTd.removeAttribute("HEIGHT");
                        //TR
                        docMapContentTd.parentNode.removeAttribute("HEIGHT");
                    }

                    sizingElement.style.height = (reportAreaHeight - docMapTitleHeight) + "px";
                }
            }
        }
    },

    OnDocMapSplitterResizing: function(sender, args)
    {
        var docMapCells = this.GetDocMapCells();
        if (docMapCells.hasNodes)
        {
            this.SetDocMapAreaWidth(docMapCells.docMapCell.clientWidth + args.get_delta());
        }
    },

    Find: function(textToFind)
    {
        if (typeof textToFind != "string" || textToFind.length == 0)
            return;

        this.InvokeInteractivityPostBack("Find", textToFind);
    },

    // Returns true if the action was entirely handled on the client, false if a postback was required.
    FindNext: function()
    {
        var reportObject = this.GetReportAreaObject();

        // Everything gets hooked up by the load event.  But be safe in case someone
        // calls this too early.
        if (reportObject == null)
            return true;

        // Try to handle the search on the client (next hit is on current page)
        if (reportObject.HighlightNextSearchHit())
            return true;

        // Need to post back to get the page with the next hit
        this.InvokeInteractivityPostBack("FindNext", null);
        return false;
    },

    get_zoomLevel: function()
    {
        var reportObject = this.GetReportAreaObject();
        if (reportObject == null)
            return 100;
        return reportObject.get_zoomLevel();
    },

    set_zoomLevel: function(zoomValue)
    {
        var reportObject = this.GetReportAreaObject();
        if (reportObject == null)
            return;
        reportObject.set_zoomLevel(zoomValue);
    },

    RefreshReport: function()
    {
        this.InvokeInteractivityPostBack("Refresh", null);
    },

    get_reportAreaContentType: function()
    {
        var reportAreaObject = this.GetReportAreaObject();
        if (reportAreaObject == null)
            return Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;
        return reportAreaObject.get_contentType();
    },

    OnUserCanceled: function(value)
    {
        var reportArea = $find(this.ReportAreaId);
        reportArea._OnUserCanceled();

        this.EnableDisableInput(true);
    },

    GetDirection: function()
    {
        // Cache the current direction so the server can keep track
        var directionField = $get(this.DirectionCacheId);

        var viewer = $get(this.ReportViewerId);
        directionField.value = Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection(viewer);
        return directionField.value;
    },

    GetToolBarUpdate: function()
    {
        return this.m_toolBarUpdate;
    },

    GetReportAreaObject: function()
    {
        var reportElement = $get(this.ReportAreaId);
        if (reportElement != null)
            return reportElement.control;
        else
            return null;
    },

    GetPageRequestManager: function()
    {
        if (Sys.WebForms)
            return Sys.WebForms.PageRequestManager.getInstance();
        else
            return null;
    },

    InvokeInteractivityPostBack: function(actionType, actionParam)
    {
        $get(this.ActionTypeId).value = actionType;
        $get(this.ActionParamId).value = actionParam;
        this.PostBackToClientScript();
    },

    UpdateBrowserMode: function()
    {
        var browserModeId = this.BrowserModeId;
        if (browserModeId)
        {
            var browserModeField = $get(browserModeId);
            browserModeField.value = _$RVCommon.isQuirksMode() ? "quirks" : "standards";
        }
    }
}

Microsoft.Reporting.WebFormsClient._InternalReportViewer.registerClass("Microsoft.Reporting.WebFormsClient._InternalReportViewer", Sys.UI.Control);

Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection = function(element)
{
    // Retrieve the cascaded direction attribute/style.
    // The currentStyle property is supported by IE.
    // Other browsers (Firefox, Safari) must use the
    // getComputedStyle method.
    if (element.currentStyle != null)
        return element.currentStyle.direction;
    else if (window.getComputedStyle != null)
    {
        var cs = window.getComputedStyle(element, null);
        return cs.getPropertyValue('direction');
    }
    return 'ltr';
}
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

// BaseParameterInputControl /////////////////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._BaseParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._BaseParameterInputControl.initializeBase(this, [element]);
    
    this.NullCheckBoxId = null;
    this.NullValueText = null;
    this.ValidationMessage = null;
    this.PostBackOnChange = false;
    this.TriggerPostBackScript = null;
    this.TextBoxEnabledClass = null;
    this.TextBoxDisabledClass = null;
    this.TextBoxDisabledColor = null;
    
    this.m_validatorIds = new Array(0);
    this.m_customInputControlIds = new Array(0);
}

Microsoft.Reporting.WebFormsClient._BaseParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._BaseParameterInputControl.callBaseMethod(this, "initialize");

        if (this.NullCheckBoxId != null)
        {
            $addHandlers($get(this.NullCheckBoxId),
                { "click" : this.OnNullCheckClick },
                this);
        }
    },
    
    dispose : function()
    {
        if (this.NullCheckBoxId != null)
            $clearHandlers($get(this.NullCheckBoxId));
        $clearHandlers(this.get_element());

        Microsoft.Reporting.WebFormsClient._BaseParameterInputControl.callBaseMethod(this, "dispose");
    },
    
    // Custom accessor for complex object type (array)
    set_CustomInputControlIdList : function(value) { this.m_customInputControlIds = value; },
    get_CustomInputControlIdList : function()      { return this.m_customInputControlIds; },
    set_ValidatorIdList          : function(value) { this.m_validatorIds = value; },
    get_ValidatorIdList          : function()      { return this.m_validatorIds; },

    // "Abstract" methods
    GetCurrentValue : function() { return null; },
    
    GetDisplayValue : function()
    {
        var currentValue = this.GetCurrentValue();
        if (currentValue == null)
            return "";
        else
            return currentValue;
    },
    
    SetEnableState : function(enable)
    {
        var enableNonNullControls = enable;

        if (this.NullCheckBoxId != null)
        {
            this.SetInputControlEnableState(this.NullCheckBoxId, enable);
            
            var nullCheckBox = $get(this.NullCheckBoxId);
            
            // If enabling, non-null controls are enabled only if null
            // checkbox is unchecked.  If disabling, non-null controls
            // should be disabled regardless of the null checkbox state.
            enableNonNullControls = enable && !nullCheckBox.checked;
        }
        
        // Update associated validators
        for (var i = 0; i < this.m_validatorIds.length; i++)
        {
            this.SetValidatorEnableState(this.m_validatorIds[i], enableNonNullControls);
        }
        
        // Update input controls other than the null check box
        for (var i = 0; i < this.m_customInputControlIds.length; i++)
        {
            this.SetInputControlEnableState(this.m_customInputControlIds[i], enableNonNullControls)
        }
    },
    
    ValidateHasValue : function()
    {
        if (this.GetCurrentValue() == null)
        {
            alert(this.ValidationMessage);
            return false;
        }
        else
            return true;
    },

    IsNullChecked : function()
    {
        if (this.NullCheckBoxId != null)
            return $get(this.NullCheckBoxId).checked;
        else
            return false;
    },
    
    OnNullCheckClick : function(e)
    {
        if (this.PostBackOnChange && this.GetCurrentValue() != null)
            this.TriggerPostBackScript();
            
        this.SetEnableState(true);
    },
    
    SetValidatorEnableState : function(validatorId, enable)
    {
        var validator = $get(validatorId);
        if (validator != null)
        {
            validator.enabled = enable;

            // Hide disabled validators
            if (!validator.enabled)
                ValidatorValidate(validator);
        }
    },
    
    SetInputControlEnableState : function(controlId, enable)
    {
        var control = $get(controlId);

        // ASP sets the disabled tag on a span that contains the radio button
        if (control.type == "radio" || control.type == "checkbox")
            control.parentNode.disabled = !enable;
        else if (control.type == "text")
        {
            if (!enable)
            {
                control.className = this.TextBoxDisabledClass;
                control.style.backgroundColor = this.TextBoxDisabledColor;
            }
            else
            {
                control.className = this.TextBoxEnabledClass;
                control.style.backgroundColor = "";
            }
        }

        control.disabled = !enable;
    }
}

Microsoft.Reporting.WebFormsClient._BaseParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._BaseParameterInputControl", Sys.UI.Control);
//////////////////////////////////////////////////////////////////////////////////////////////////////


// TextParameterInputControl /////////////////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._TextParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._TextParameterInputControl.initializeBase(this, [element]);
    
    this.TextBoxId = null;
    this.AllowBlank = false;
}

Microsoft.Reporting.WebFormsClient._TextParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._TextParameterInputControl.callBaseMethod(this, "initialize");
    },
    
    dispose : function()
    {
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient._TextParameterInputControl.callBaseMethod(this, "dispose");
    },
    
    GetCurrentValue : function()
    {
        if (this.IsNullChecked())
            return this.NullValueText;
        else
        {
            var txtInput = $get(this.TextBoxId);
            
            if (txtInput.value == "" && !this.AllowBlank)
                return null;
            else
                return txtInput.value;
        }
    }
}

Microsoft.Reporting.WebFormsClient._TextParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._TextParameterInputControl", Microsoft.Reporting.WebFormsClient._BaseParameterInputControl);
//////////////////////////////////////////////////////////////////////////////////////////////////////


// BoolParameterInputControl /////////////////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._BoolParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._BoolParameterInputControl.initializeBase(this, [element]);

    this.TrueCheckId = null;
    this.FalseCheckId = null;

    this.TrueValueText = null;
    this.FalseValueText = null;
}

Microsoft.Reporting.WebFormsClient._BoolParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._BoolParameterInputControl.callBaseMethod(this, "initialize");
        
        // Call the boolean disabled script to ensure the client is in the correct state for non IE browsers
        if (this.NullCheckBoxId != null)
        {
            var isNullChecked = this.IsNullChecked();
            this.SetInputControlEnableState(this.TrueCheckId, !isNullChecked);
            this.SetInputControlEnableState(this.FalseCheckId, !isNullChecked);
        }
    },
    
    dispose : function()
    {
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient._BoolParameterInputControl.callBaseMethod(this, "dispose");
    },
    
    GetCurrentValue : function()
    {
        if (this.IsNullChecked())
            return this.NullValueText;
        else
        {
            var chkTrue = $get(this.TrueCheckId);
            var chkFalse = $get(this.FalseCheckId);

            if (chkTrue.checked)
                return this.TrueValueText;
            else if (chkFalse.checked)
                return this.FalseValueText;
            else
                return null;
        }
    }
}

Microsoft.Reporting.WebFormsClient._BoolParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._BoolParameterInputControl", Microsoft.Reporting.WebFormsClient._BaseParameterInputControl);
//////////////////////////////////////////////////////////////////////////////////////////////////////


// ValidValueParameterInputControl ///////////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl.initializeBase(this, [element]);
    
    this.DropDownId = null;
    this.DropDownValidatorId = null;
    this.m_hasSelectAValue = true;
}

Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl.callBaseMethod(this, "initialize");
        
        this.RemoveSelectAValueIfNotSelected();
        
        $addHandlers($get(this.DropDownId),
            { "change" : this.RemoveSelectAValueIfNotSelected },
            this);
    },
    
    dispose : function()
    {
        $clearHandlers($get(this.DropDownId));
        
        Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl.callBaseMethod(this, "dispose");
    },

    GetCurrentValue : function()
    {
        var dropDown = $get(this.DropDownId);

        if (dropDown.selectedIndex > 0 || !this.m_hasSelectAValue)
            return dropDown.options[dropDown.selectedIndex].text;
        else
            return null;
    },
    
    RemoveSelectAValueIfNotSelected : function()
    {   
        if (this.m_hasSelectAValue)
        {
            var dropDown = $get(this.DropDownId);
            
            // If something other than "select a value" is selected
            if (dropDown.selectedIndex > 0)
            {
                // dropDown.offsetWidth can be zero if dropDown is hidden.
                if (dropDown.offsetWidth > 0)
                {
                    // If the "select a value" option is the longest one in the drop down,
                    // removing it will shrink the size of the dropdown.  This looks strange,
                    // so maintain the dropdown width.
                    dropDown.style.width = dropDown.offsetWidth + "px";
                }
                
                dropDown.remove(0);
                this.m_hasSelectAValue = false;
                
                // Now that the "select a value" option is removed,
                // the drop down validator is no longer necessary.
                // We cannot just disable the validator, since it
                // could be re-enabled by some client action.  Instead,
                // we just set the client validation function to null so
                // no actual validation occurs.
                if (this.DropDownValidatorId != null)
                {
                    var validator = $get(this.DropDownValidatorId);
                    if (validator != null)
                        validator.clientvalidationfunction = null;
                }
            }
        }
    }
}

Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._ValidValueParameterInputControl", Microsoft.Reporting.WebFormsClient._BaseParameterInputControl);
//////////////////////////////////////////////////////////////////////////////////////////////////////

// GenericDropDownParameterInputControl //////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.initializeBase(this, [element]);
    
    this.EnabledImageSrc = null;
    this.DisabledImageSrc = null;
    this.ImageId = null;
    this.TextBoxId = null;
    this.FloatingIframeId = null;
    this.RelativeDivId = null;
}

Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.callBaseMethod(this, "initialize");

        $addHandlers($get(this.ImageId),
            { "click" : this.OnDropDownImageClick },
            this);
    },
    
    dispose : function()
    {
        $clearHandlers($get(this.ImageId));
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.callBaseMethod(this, "dispose");
    },
    
    OnDropDownImageClick : function(e)
    {
        this.ToggleFloatingFrameVisibility();
        e.stopPropagation();
        e.preventDefault();
    },
    
    SetEnableState : function(enable)
    {
        Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.callBaseMethod(this, "SetEnableState", [enable]);

        var inputCtrl = $get(this.ImageId);
        this.SelectImage(!inputCtrl.disabled);
    },
    
    SelectImage : function(useEnabledImage)
    {
        var inputCtrl = $get(this.ImageId);
        if (useEnabledImage)
        {
            inputCtrl.src = this.EnabledImageSrc;
            inputCtrl.style.cursor = 'pointer';
        }
        else
        {
            inputCtrl.src = this.DisabledImageSrc;
            inputCtrl.style.cursor = 'default';
        }    
    },
    
    ToggleFloatingFrameVisibility : function()
    {
        var floatingIframe = $get(this.FloatingIframeId);
        if (floatingIframe.style.display == "none")
            this.ShowFloatingFrame();
        else
            this.HideFloatingFrame();
    },
    
    ShowFloatingFrame : function()
    {
        var floatingIFrame = $get(this.FloatingIframeId);

        // Position the drop down. This must be done before making the frame visible. Otherwise, 
        // a scroll bar is likely to appear as a result of showing the frame which would make the 
        // position invalid.
        if (this.RelativeDivId == null)
        {
            var newDropDownPosition = this.GetDropDownPosition();
            floatingIFrame.style.left = newDropDownPosition.Left + "px";
            floatingIFrame.style.top = newDropDownPosition.Top + "px";
        }

        // only show if the frame is not currently visible.
        if (floatingIFrame.style.display != "inline")
        {
            var visibleTextBox = $get(this.TextBoxId);

            floatingIFrame.style.width = visibleTextBox.offsetWidth + "px";
            floatingIFrame.style.display = "inline";
        }

        if (this.RelativeDivId != null)
        {
            // set the zIndex of the containing div so the frame doesn't get overlapped
            // by other elements outside the containing div.
            var relativeDiv = $get(this.RelativeDivId);
            relativeDiv.style.zIndex = 1;
        }
        else
        {
            // poll for changes in screen position
            this.PollForDropDownMovement();
        }
        
        // Define an OnShowEvent event for consumers of this class.
        var handler = this.get_events().getHandler("OnShowEvent");
        if (handler != null)
            handler(this, Sys.EventArgs.Empty);
    },

    HideFloatingFrame : function()
    {
        var floatingIFrame = $get(this.FloatingIframeId);

        if (this.RelativeDivId != null)
        {
            // reset the zIndex
            var relativeDiv = $get(this.RelativeDivId);
            relativeDiv.style.zIndex = 0;
        }
        
        floatingIFrame.style.display = "none";

        var handler = this.get_events().getHandler("OnHideEvent");
        if (handler != null)
            handler(this, Sys.EventArgs.Empty);

        // When the dropdown collapses, the parameter is done changing value,
        // so perform the autopost back for dependent parameters.
        if (this.PostBackOnChange)
            this.TriggerPostBackScript();
    },
    
    GetDropDownPosition : function()
    {
        var visibleTextBox = $get(this.TextBoxId);
        var floatingIFrame = $get(this.FloatingIframeId);

        // NOTE: In mozilla, x.offsetParent can only be accessed if x is visible.
        var originalDisplay = floatingIFrame.style.display;
        floatingIFrame.style.display = "inline";
        var offsetParent = floatingIFrame.offsetParent;
        floatingIFrame.style.display = originalDisplay;

        var textBoxPosition = this.GetObjectPosition(visibleTextBox, offsetParent);

        return {Left:textBoxPosition.Left, Top:textBoxPosition.Top + visibleTextBox.offsetHeight};
    },

    GetObjectPosition : function(obj, relativeToObj)
    {
        var totalTop = 0;
        var totalLeft = 0;
        
        var parent = obj.offsetParent;
        if (parent != null) 
        {
            // this loop goes through each step along the offsetParent hierarchy except the last step.
            // in the last step we do not want to make the scrollTop/scrollLeft correction.
            while (parent != relativeToObj && parent != null)
            {
                // topToTop is the distance from the top of obj to the top of parent.
                var topToTop = obj.offsetTop - parent.scrollTop;
                totalTop += topToTop;

                // leftToLeft is the distance from the outer left edge of obj to the outer left edge of parent
                var leftToLeft = obj.offsetLeft - parent.scrollLeft;
                totalLeft += leftToLeft;

                obj = parent;
                parent = parent.offsetParent;
            }
        }
        
        // The last step is to add in the distance from the top of obj to parent (the object 
        // that we are measuring relative to).
        // Therefore the scroll top/left correction is not needed.
        totalTop += obj.offsetTop;
        totalLeft += obj.offsetLeft;

        // if the parent != relativeToObj, then it must be null (per the exit conditions of the while
        // loop). Then the relativeToObject must be the top of the offset hierarchy, which means
        // either it is null or its parent is null. If neither of these are true, then we have an 
        // error and obj is not contained within relativeToObj.
        if (parent != relativeToObj && relativeToObj != null && relativeToObj.offsetParent != null)
        {
            // invalid input, obj is not contained within relativeToObj
            return {Left:0, Top:0};
        }

        if (parent != relativeToObj && relativeToObj != null)
        {
            totalTop -= relativeToObj.offsetTop;
            totalLeft -= relativeToObj.offsetLeft;
        }

        return {Left:totalLeft, Top:totalTop};
    },
    
    PollForDropDownMovement : function()
    {
        var element = "$get('" + escape(this.get_element().id) + "')";
        setTimeout("if (" + element + " != null)" + element + ".control.PollingCallback();", 100);
    },

    PollingCallback : function()
    {
        // If the iframe isn't visible, no more events.
        var floatingIframe = $get(this.FloatingIframeId);
        if (floatingIframe.style.display != "inline")
            return;

        // If the text box moved, something on the page resized, so close the editor
        var expectedIframePos = this.GetDropDownPosition();
        if (floatingIframe.style.left != expectedIframePos.Left + "px" ||
            floatingIframe.style.top != expectedIframePos.Top + "px")
            this.HideFloatingFrame();
        else
            this.PollForDropDownMovement();
    }
}

Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl", Microsoft.Reporting.WebFormsClient._BaseParameterInputControl);
//////////////////////////////////////////////////////////////////////////////////////////////////////


// CalendarDropDownParameterInputControl /////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.initializeBase(this, [element]);
    
    this.BaseCalendarUrl = null;
}

Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.callBaseMethod(this, "initialize");
    },
    
    dispose : function()
    {
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.callBaseMethod(this, "dispose");
    },
    
    GetCurrentValue : function()
    {
        if (this.IsNullChecked())
            return this.NullValueText;
        else
        {
            var txtInput = $get(this.TextBoxId);
            if (txtInput.value == "")
                return null;
            else
                return txtInput.value;
        }
    },
    
    OnDropDownImageClick : function(e)
    {
        Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.callBaseMethod(this, "OnDropDownImageClick", [e]);

        var calendarUrl = this.BaseCalendarUrl + encodeURIComponent($get(this.TextBoxId).value);
        this.SetCalendarUrl(calendarUrl, false);
    },
    
    OnCalendarSelection : function(resultfield)
    {
        // When the calendar is collapsing as a result of having a date selected, the calendar itself
        // has the focus.  Move the focus to the calendar button.  Otherwise IE can get into a state
        // where it won't allow anything to have the focus.
        var inputCtrl = $get(this.ImageId);
        inputCtrl.focus();
        
        this.ToggleFloatingFrameVisibility();

        this.SetCalendarUrl(this.BaseCalendarUrl + encodeURIComponent(resultfield.value), true);
    },
    
    SetCalendarUrl : function(url, forceReload)
    {
        var iframeObject = $get(this.FloatingIframeId).contentWindow;
        
        if (!forceReload) 
        {
            // If the selected dates are the different then get a new page
            var currentDate = this.GetSelectedDateFromUrl(iframeObject.document.location.search).toUpperCase();
            var newDate = this.GetSelectedDateFromUrl(url).toUpperCase();
            if (currentDate == newDate)
            {
                if (iframeObject.document.readyState == "complete")
                {
                    // Hide the calendar that is showing and make sure the one with the 
                    // users selection is showing.
                    iframeObject.HideUnhide(iframeObject.g_currentShowing, "DatePickerDiv", iframeObject.g_currentID, null);
                    return;
                }
            }
        }

        if (iframeObject.document.readyState == "complete")
        {
            // Show the loading page if navigating to a new calendar
            iframeObject.Hide(iframeObject.g_currentShowing);
            iframeObject.Unhide("LoadingDiv");
        }
        
        iframeObject.document.location.replace(url);
    },
    
    GetSelectedDateFromUrl : function(url)
    {
        var pos = url.lastIndexOf("selectDate");
        var date = null;
        
        if (pos != -1)
        {
            date = url.substring(pos);
            pos = date.indexOf("=");
            
            if (pos == -1)
                date = null;
            else
            {
                date = date.substring(pos + 1);
                
                pos = date.indexOf("&");
                if (pos != -1)
                    date = date.substring(0, pos);
            }
        }
        
        return date;
    }
}

Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._CalendarDropDownParameterInputControl", Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl);
//////////////////////////////////////////////////////////////////////////////////////////////////////

// MultiValueParameterInputControl ///////////////////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.initializeBase(this, [element]);

    this.HasValidValueList = false;
    this.AllowBlank = false;
    this.FloatingEditorId = null;
    this.HiddenIndicesId = null;
    this.TextAreaDelimiter = _$RVCommon.getNewLineDelimiter();
    this.ListSeparator = null;
    this.GripImage = null;
    this.GripImageRTL = null;

    this.m_hiddenIndices = null;
    this.m_table = null;
}

Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.callBaseMethod(this, "initialize");

        if (this.HasValidValueList)
        {
            // ValidValueList initialization
            this.m_hiddenIndices = $get(this.HiddenIndicesId);
            var floatingEditor = $get(this.FloatingEditorId);
            this.m_table = floatingEditor.getElementsByTagName("TABLE")[0];
        }

        $addHandlers($get(this.TextBoxId),
            { "click": this.OnTextBoxClick },
            this);

        this.UpdateTextBoxWithDisplayValue();

        // remove the checkboxes from the DOM, restore them only when needed (ShowFloatingFrame), this prevents
        // the checkboxes from posting back in the case where the dropdown was never expanded
        this.RemoveCheckBoxes();
    },

    dispose: function()
    {
        $clearHandlers(this.get_element());
        $clearHandlers($get(this.TextBoxId));

        if (this._resizeBehavior)
        {
            this._resizeBehavior.dispose();
            delete this._resizingDelegate;
        }

        if (this.HasValidValueList)
        {
            this.m_hiddenIndices = null;
            this.m_table = null;
        }

        Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.callBaseMethod(this, "dispose");
    },

    OnTextBoxClick: function(e)
    {
        this.ShowFloatingFrame();
        e.stopPropagation();
    },

    GetCurrentValue: function()
    {
        if (this.HasValidValueList)
            return this.GetCurrentValueFromValidValueList();
        else
            return this.GetCurrentValueFromTextEditor();
    },

    GetCurrentValueFromTextEditor: function()
    {
        var span = $get(this.FloatingEditorId);
        var editor = span.getElementsByTagName("TEXTAREA")[0];

        var valueString = editor.value;

        // Remove the blanks
        if (!this.AllowBlank)
        {
            // Break down the text box string to the individual lines
            var valueArray = valueString.split(this.TextAreaDelimiter);

            var finalValue = "";
            for (var i = 0; i < valueArray.length; i++)
            {
                // If the string is non-blank, add it
                if (valueArray[i].length > 0)
                {
                    if (finalValue.length > 0)
                        finalValue += this.ListSeparator;
                    finalValue += valueArray[i];
                }
            }

            if (finalValue.length == 0)
                return null;
            else
                return finalValue;
        }
        else
            return valueString.replace(new RegExp(this.TextAreaDelimiter, "g"), this.ListSeparator);
    },

    GetCurrentValueFromValidValueList: function()
    {
        // using a Sys.StringBuilder to optimize for speed
        var valueString = new Sys.StringBuilder();
        var indexString = new Sys.StringBuilder();

        // If there is only one element, it is a real value, not the select all option
        var startIndex = 0;
        var length = this.m_table.rows.length; // cache the length
        if (length > 1)
            startIndex = 1;

        for (var i = startIndex; i < length; i++)
        {
            var rowInfo = this.GetValueForMultiValidValueRow(this.m_table, i);

            if (rowInfo.CheckBox.checked)
            {
                valueString.append(this.Trim(rowInfo.Label));
                indexString.append((i - startIndex).toString());
            }
        }

        // hiddenIndices is populated with a comma separated list of indices of the checked checkboxes
        this.m_hiddenIndices.value = indexString.toString(','); // parameter is the separator

        if (valueString.isEmpty())
            return null;
        else
            return valueString.toString(this.ListSeparator); // parameter is the separator
    },

    GetValueForMultiValidValueRow: function(table, rowIndex)
    {
        // Get the first cell of the row
        var firstCell = table.rows[rowIndex].cells[0];
        var span = firstCell.childNodes[0];

        var checkBox = span.childNodes[0];

        // Span is not always generated.
        var label;
        if (span.nodeName == "INPUT")
        {
            checkBox = span;
            label = firstCell.childNodes[1];
        }
        else
            label = span.childNodes[1];

        var labelStr = " ";
        if (label != null)
        {
            labelStr = label.innerText || label.textContent;

            // The label can be blank.  If it is zero length, make it a space so that
            // the text summary a little easier to read.
            if (typeof (labelStr) !== "string" || labelStr === "")
                labelStr = " ";
        }

        return { CheckBox: checkBox, Label: labelStr };
    },

    // Trim leading and trailing spaces (NBSP) from a string
    Trim: function(text)
    {
        var startpos = text.length;
        var nbsp = 160; // Remove occurrances of NBSP
        for (var i = 0; i < text.length; i++)
        {
            // Look for &nbsp
            if (text.charCodeAt(i) != nbsp)
            {
                startpos = i;
                break;
            }
        }
        var endpos = text.length - 1;
        for (var j = endpos; j >= startpos; j--)
        {
            if (text.charCodeAt(j) != nbsp)
            {
                endpos = j;
                break;
            }
        }
        endpos++;
        return text.substring(startpos, endpos);
    },

    UpdateTextBoxWithDisplayValue: function()
    {
        var textBox = $get(this.TextBoxId);
        textBox.value = this.GetDisplayValue();
    },

    RemoveCheckBoxes: function()
    {
        if (this.m_table != null)
        // remove the table of checkboxes from the DOM
            this.m_table.parentNode.removeChild(this.m_table);
    },

    RestoreCheckBoxes: function()
    {
        if (this.m_table != null)
        // insert the table back in front of the hidden field
            this.m_hiddenIndices.parentNode.insertBefore(this.m_table, this.m_hiddenIndices);
    },

    ShowFloatingFrame: function()
    {
        var floatingEditor = $get(this.FloatingEditorId);

        if (this.RelativeDivId == null)
        {
            // Position the drop down.  This must be done before calling showing the frame. Otherwise, 
            // a scroll bar is likely to appear as a result of the frame becoming visible which would make the 
            // position invalid.
            var newEditorPosition = this.GetDropDownPosition();
            floatingEditor.style.left = newEditorPosition.Left + "px";
            floatingEditor.style.top = newEditorPosition.Top + "px";
        }

        // only show if the editor is not currently visible. 
        if (floatingEditor.style.display == "inline")
            return;

        // Restore the checkboxes into the DOM
        this.RestoreCheckBoxes();

        // Set drop down and summary string to the same width to make it look like a drop down
        var visibleTextBox = $get(this.TextBoxId);
        floatingEditor.style.width = visibleTextBox.offsetWidth + "px";

        floatingEditor.style.display = "inline";

        // Show the iframe
        Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.callBaseMethod(this, "ShowFloatingFrame");

        // Set the iframe height to our controls height
        var floatingIFrame = $get(this.FloatingIframeId);
        floatingIFrame.style.height = floatingEditor.offsetHeight;

        if (!(this._resizeBehavior))
            this._attachResizeHandle()
        else
            this._resizeBehavior._reset();
    },

    _attachResizeHandle: function()
    {
        var floatingEditor = $get(this.FloatingEditorId);
        if (this.HasValidValueList)
        {
            if (floatingEditor.offsetWidth > floatingEditor.scrollWidth &&
                floatingEditor.offsetHeight > floatingEditor.scrollHeight)
            {
                // no need of resizable behavior;
                return;
            }
        }

        // If we have horizontal overflow, horizontal scrollbar appears.
        // Increase the minimum height, if is less that 200px, so the last row to be visible.
        // This compensation have to be done only for IE < 8
        var scrollCompensation = 0;
        if (Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.documentMode < 8)
        {
            scrollCompensation = Math.max(0, (floatingEditor.offsetHeight - floatingEditor.clientHeight));
        }
        var minimumHeight = Math.min(150, floatingEditor.offsetHeight + scrollCompensation);
        var minimumWidth = parseInt(floatingEditor.style.width) - parseInt(floatingEditor.style.borderWidth) * 2;

        // the textarea must have overflow set in the server code.
        var resizeOverfow = this.HasValidValueList ? "auto" : "hidden";

        if (!this.HasValidValueList)
        {
            this._textArea = floatingEditor.getElementsByTagName("textarea")[0];
            // Firefox includes the scrollbars in the padding for text areas, despite outer box model. 
            if (Sys.Browser.agent == Sys.Browser.Firefox)
            {
                this._textArea.style.padding = "0px";
            }
        }
        this._resizeBehavior = $create(Microsoft.Reporting.WebFormsClient.ResizableControlBehavior,
                {
                    GripImage: this.GripImage,
                    GripImageRTL: this.GripImageRTL,
                    MinimumHeight: minimumHeight,
                    MinimumWidth: minimumWidth,
                    Overflow: resizeOverfow,
                    id: this.FloatingEditorId + "_resize"
                }, null, null, floatingEditor
        );
        this._resizingDelegate = Function.createDelegate(this, this._onResizing)
        this._resizeBehavior.add_resizing(this._resizingDelegate);
    },

    _onResizing: function(sender, args)
    {
        var floatingEditor = $get(this.FloatingEditorId);
        var floatingIFrame = $get(this.FloatingIframeId);
        var size = sender.get_Size();
        // check if the frame is displayed first to reduce flickering.
        if (floatingIFrame.style.display != "block")
        {
            floatingIFrame.style.display = "block";
        }

        // The size of the text area have to be set explicitly.
        if (!this.HasValidValueList && this._textArea)
        {
            if (_$RVCommon.isIEQuirksMode())
            {
                this._textArea.style.width = size.width + "px";
                this._textArea.style.height = size.height + "px";
            }
            else
            {
                // standard box mode include padding;
                var padding = (parseInt(this._textArea.style.padding) * 2);
                this._textArea.style.width = size.width - padding + "px";
                this._textArea.style.height = size.height - padding + "px";
            }
        }

        floatingIFrame.style.left = floatingEditor.style.left;
        floatingIFrame.style.width = size.width + "px";
        floatingIFrame.style.height = size.fullHeight + "px";
    },

    HideFloatingFrame: function()
    {
        var floatingEditor = $get(this.FloatingEditorId);

        // Hide the editor
        floatingEditor.style.display = "none";

        // Update the text box
        this.UpdateTextBoxWithDisplayValue();

        // remove the checkboxes from the DOM
        this.RemoveCheckBoxes();

        // Hide the iframe
        Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.callBaseMethod(this, "HideFloatingFrame");
    },

    SetDefaultChecked: function(src)
    {
        // IE6 reverts the checked state to that of the defaultChecked value when removed from the DOM, we need to 
        // update the value so that the value is correct when retrieved while not in the DOM (i.e. "View Report")
        if (Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.version == 6)
            src.defaultChecked = src.checked;
    },

    OnSelectAllClick: function(src)
    {
        this.SetDefaultChecked(src);
        var length = this.m_table.rows.length; // cache the value of the length
        for (var i = 1; i < length; i++)
        {
            var rowInfo = this.GetValueForMultiValidValueRow(this.m_table, i);

            rowInfo.CheckBox.checked = src.checked;
            this.SetDefaultChecked(rowInfo.CheckBox);
        }
    },

    OnValidValueClick: function(src, selectAllCheckBoxId)
    {
        if (!src.checked && selectAllCheckBoxId != '')
        {
            var selectAllCheckBox = $get(selectAllCheckBoxId);
            selectAllCheckBox.checked = false;
            this.SetDefaultChecked(selectAllCheckBox);
        }
        this.SetDefaultChecked(src);
    }
}

Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl.registerClass("Microsoft.Reporting.WebFormsClient._MultiValueParameterInputControl", Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl);

//////////////////////////////////////////////////////////////////////////////////////////////////////
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._PromptArea = function(element)
{
    Microsoft.Reporting.WebFormsClient._PromptArea.initializeBase(this, [element]);

    this.ReportViewerId = null;

    this.CredentialsLinkId = null;
    this.ParametersGridID = null;
    this.ViewReportButtonId = null;

    this.m_activeDropDown = null;
    this.m_parameterIdList = null;
    this.m_credentialIdList = null;
    this.m_hookedEvents = false;

    this.m_onReportViewerLoadingChangedDelegate = Function.createDelegate(this, this.OnReportViewerLoadingChanged);
}

Microsoft.Reporting.WebFormsClient._PromptArea.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._PromptArea.callBaseMethod(this, "initialize");

        var viewReportButton = $get(this.ViewReportButtonId);

        if (viewReportButton != null)
        {
            $addHandlers($get(this.ViewReportButtonId),
                { "click": this.OnViewReportClick },
                this);
        }

        if (this.ReportViewerId != null)
        {
            var reportViewer = $find(this.ReportViewerId);
            if (reportViewer != null)
                reportViewer.add_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
        }
    },

    dispose: function()
    {
        var viewReportButton = $get(this.ViewReportButtonId);

        if (viewReportButton != null)
            $clearHandlers(viewReportButton);

        if (this.ReportViewerId != null)
        {
            var reportViewer = $find(this.ReportViewerId);
            if (reportViewer != null)
                reportViewer.remove_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
        }
        
        $clearHandlers(this.get_element());

        delete this.m_onReportViewerLoadingChangedDelegate;
        this.m_onReportViewerLoadingChangedDelegate = null;

        Microsoft.Reporting.WebFormsClient._PromptArea.callBaseMethod(this, "dispose");
    },

    // Custom accessor for complex object type (array)
    set_ParameterIdList: function(value) { this.m_parameterIdList = value; },
    get_ParameterIdList: function() { return this.m_parameterIdList; },
    set_CredentialIdList: function(value) { this.m_credentialIdList = value; },
    get_CredentialIdList: function() { return this.m_credentialIdList; },

    ShouldValidateParameters: function()
    {
        if (this.m_parameterIdList == null)
            return false;

        // Get the credential link
        var credentialLink = $get(this.CredentialsLinkId);

        // The credential link is not rendered in 2 cases.
        // 1 - There are no credentials.  If there are no credentials but there
        //     is a prompt area at all, then it must have parameters which should
        //     then be validated.
        // 2 - The credential prompts are being shown initially because they aren't
        //     satisfied.  In this case, there are no rendered parameter prompts, so
        //     it does't hurt to validate all 0 of them.
        if (credentialLink == null)
            return true;

        // Initial view was of parameters and it still is
        return credentialLink.style.display != "none";
    },

    ShouldValidateCredentials: function()
    {
        if (this.m_credentialIdList == null)
            return false;

        // Get the credential link
        var credentialLink = $get(this.CredentialsLinkId);

        // The credential link is not rendered in 2 cases.
        // 1 - There are no credentials.  In this case, validating all 0 of them
        //     does no harm.
        // 2 - The credential prompts are being shown initially because they aren't
        //     satisfied.  In this case, we always want to validate the input boxes.
        // Therefore, if there is no credential link, validate the credentials.
        if (credentialLink == null)
            return true;

        // Switched back from intial view of parameters to credentials
        return credentialLink.style.display == "none";
    },

    ValidateInputs: function()
    {
        if (this.ShouldValidateCredentials())
        {
            for (var i = 0; i < this.m_credentialIdList.length; i++)
            {
                var credentialElement = $get(this.m_credentialIdList[i]);
                var credentialControl = credentialElement.control;
                if (!credentialControl.ValidateHasValue())
                    return false;
            }
        }

        if (this.ShouldValidateParameters())
        {
            for (var i = 0; i < this.m_parameterIdList.length; i++)
            {
                var parameterElement = $get(this.m_parameterIdList[i]);
                var parameterControl = parameterElement.control;
                if (!parameterControl.ValidateHasValue())
                    return false;
            }
        }

        return true;
    },

    OnViewReportClick: function(e)
    {
        if (!this.ValidateInputs())
            e.preventDefault();
    },

    OnChangeCredentialsClick: function()
    {
        // Hide the link
        var credentialLink = $get(this.CredentialsLinkId);
        credentialLink.style.display = "none";

        // Make sure each row in the table is visible
        var paramsTable = $get(this.ParametersGridID);
        for (var i = 0; i < paramsTable.rows.length; i++)
        {
            var row = paramsTable.rows[i];
            var makeVisible = row.attributes.getNamedItem("IsParameterRow") == null;
            _$RVCommon.SetElementVisibility(row, makeVisible);
        }
        
        // Changing which rows are visible can affect the height of the prompt area.  Need to recalc layout.
        if (this.ReportViewerId != null)
        {
            var reportViewer = $find(this.ReportViewerId);
            reportViewer.recalculateLayout();
        }
    },

    HookParameterEvents: function()
    {
        if (this.m_hookedEvents || this.m_parameterIdList == null)
            return;

        for (var i = 0; i < this.m_parameterIdList.length; i++)
        {
            var parameterObject = $get(this.m_parameterIdList[i]).control;
            if (Microsoft.Reporting.WebFormsClient._GenericDropDownParameterInputControl.isInstanceOfType(parameterObject))
            {
                parameterObject.get_events().addHandler("OnShowEvent", Function.createDelegate(this, this.OnNewActiveDropDown));
                parameterObject.get_events().addHandler("OnHideEvent", Function.createDelegate(this, this.OnActiveDropDownHidden));
            }
        }

        this.m_hookedEvents = true;
    },

    OnNewActiveDropDown: function(sender, eventArgs)
    {
        // Hide the previously visible dropDown
        if (this.m_activeDropDown != sender && this.m_activeDropDown != null)
            this.m_activeDropDown.HideFloatingFrame();

        this.m_activeDropDown = sender;
    },

    OnActiveDropDownHidden: function(sender, eventArgs)
    {
        // Check that it is still listed as active, in case event ordering
        // caused the show on the new one to fire first
        if (this.m_activeDropDown == sender)
            this.m_activeDropDown = null;
    },

    HideActiveDropDown: function()
    {
        if (this.m_activeDropDown != null)
            this.m_activeDropDown.HideFloatingFrame();
    },

    OnReportViewerLoadingChanged : function(sender, e)
    {
        if (e.get_propertyName() == "isLoading")
        {
            var reportViewer = $find(this.ReportViewerId);

            var isLoading = reportViewer.get_isLoading();
            
            var shouldEnable = false;
            if (!isLoading)
            {
                var reportAreaContentType = reportViewer.get_reportAreaContentType();
                shouldEnable = reportAreaContentType != Microsoft.Reporting.WebFormsClient.ReportAreaContent.WaitControl;            
            }

            this.EnableDisableInput(shouldEnable);
        }
    },

    EnableDisableInput: function(shouldEnable)
    {
        if (shouldEnable)
            this.HookParameterEvents();

        // Enable/Disable UI elements.  If enabling and about to trigger a postback
        // (which would just disable things again), skip the enable.
        if (!shouldEnable || !Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected)
        {
            //Update the ViewReport Button
            if (this.ViewReportButtonId)
            {
                var button = $get(this.ViewReportButtonId);
                if (button)
                    button.disabled = !shouldEnable;
            }

            //Update all the credential controls
            if (this.m_credentialIdList)
            {
                for (var i = 0; i < this.m_credentialIdList.length; i++)
                {
                    var credentialElement = $get(this.m_credentialIdList[i]);
                    var credentialControl = credentialElement.control;
                    credentialControl.SetEnableState(shouldEnable);
                }
            }
            
            //Update all the parameter controls
            if (this.m_parameterIdList)
            {
                for (var i = 0; i < this.m_parameterIdList.length; i++)
                {
                    var parameterElement = $get(this.m_parameterIdList[i]);
                    var parameterControl = parameterElement.control;
                    parameterControl.SetEnableState(shouldEnable);
                }
            }
        }
    }
}

Microsoft.Reporting.WebFormsClient._PromptArea.registerClass("Microsoft.Reporting.WebFormsClient._PromptArea", Sys.UI.Control);



// DataSourceCredential /////////////////////////////////////////////////////
Microsoft.Reporting.WebFormsClient.DataSourceCredential = function(element)
{
    Microsoft.Reporting.WebFormsClient.DataSourceCredential.initializeBase(this, [element]);
    
    this.UserNameId = null;
    this.PasswordId = null;
    this.ValidationMessage = null;
}

Microsoft.Reporting.WebFormsClient.DataSourceCredential.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient.DataSourceCredential.callBaseMethod(this, "initialize");
    },
    
    dispose : function()
    {
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient.DataSourceCredential.callBaseMethod(this, "dispose");
    },

    ValidateHasValue : function()
    {
        var userControl = $get(this.UserNameId);
        if (userControl.value == "")
        {
            alert(this.ValidationMessage);
            return false;
        }
        return true;
    },
    
    SetEnableState : function(shouldEnable)
    {
        if(this.UserNameId)
        {
            var userControl = $get(this.UserNameId);
            userControl.disabled = !shouldEnable;
        }
            
        if(this.PasswordId)
        {
            var passwordControl = $get(this.PasswordId)
            passwordControl.disabled = !shouldEnable;
        }
    }    
}

Microsoft.Reporting.WebFormsClient.DataSourceCredential.registerClass("Microsoft.Reporting.WebFormsClient.DataSourceCredential", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._ReportArea = function(element)
{
    Microsoft.Reporting.WebFormsClient._ReportArea.initializeBase(this, [element]);

    // MaintainPosition
    this.m_previousViewportOffset = null; // Previous distance of the alignment object from the upper left corner of the visible area

    // AvoidScrolling
    this.m_previousScrollOffset = null;

    this.VisibleReportContentContainerId = null;
    this.ReportControlId = null;
    this.NonReportContentId = null;
    this.ScrollPositionId = null;
    this.ReportAreaVisibilityStateId = null;

    // Only used for checking when the report page changes.  Use this.GetReportPage() to access the visible element.
    this.m_currentReportPage = null;

    this.m_contentTypeToMakeVisibleOnNextLoad = Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;
    this.m_isNewContentForNonReportContentArea = false;

    this.m_lastReportPageCellId = null;

    this.m_hookReportObjectLoadedDelegate = Function.createDelegate(this, this.HookReportObjectLoaded);
    this.m_onReportPageLoadedDelegate = Function.createDelegate(this, this.OnReportPageLoaded);

    this.m_userCanceled = false;
}

Microsoft.Reporting.WebFormsClient._ReportArea.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._ReportArea.callBaseMethod(this, "initialize");

        // Listen for new instances of the report object from async postbacks
        Sys.Application.add_load(this.m_hookReportObjectLoadedDelegate);

        $addHandlers(this.get_element(),
            { "scroll": this.OnScroll,
                "resize": this.OnScroll
            },
            this);
    },

    dispose: function()
    {
        if (this.VisibleReportContentContainerId)
        {
            //Remove the report from the visible container to speed up ASP.Net dispose.
            //ASP.Net walks the DOM looking for dispose calls.  Since the report is solely HTML,
            //there are no controls to dispose, so it's safe to remove.
            var visibleContainer = $get(this.VisibleReportContentContainerId);
            if (visibleContainer && visibleContainer.childNodes.length > 0)
            {
                visibleContainer.removeChild(visibleContainer.childNodes[0]);
            }
        }

        $clearHandlers(this.get_element());

        Sys.Application.remove_load(this.m_hookReportObjectLoadedDelegate);
        delete this.m_hookReportObjectLoadedDelegate;

        delete this.m_onReportPageLoadedDelegate;

        Microsoft.Reporting.WebFormsClient._ReportArea.callBaseMethod(this, "dispose");
    },

    HookReportObjectLoaded: function()
    {
        var reportPage = this.GetReportPage();
        if (reportPage != null && reportPage != this.m_currentReportPage)
        {
            // Save off the old report cell ID before removing the reference to the last report page.
            this.m_lastReportCellId = null;
            if (this.m_currentReportPage != null)
                this.m_lastReportCellId = this.m_currentReportPage.ReportCellId;

            this.m_currentReportPage = reportPage;

            // event will be disconnected by report object dispose
            reportPage.add_allContentLoaded(this.m_onReportPageLoadedDelegate);
        }
    },

    IsLoading: function()
    {
        var reportPage = this.GetReportPage();
        return reportPage == null || reportPage.IsLoading();
    },

    //Start a timer in case the call to MakeReportVisible ThreadAborts.  The MakeReportVisible will keep creating timers until the Renderer code completes and the spinny hides.
    ListenForRenderingTimeout: function(targetReportArea)
    {
        if (!targetReportArea)
            return;

        var timeoutFunction = function()
        {
            //When the timeout fires, "this" will be the window, so the ReportArea must be a variable.
            if (targetReportArea.m_renderingTimeout != null)
            {
                targetReportArea.m_renderingTimeout = null;
                targetReportArea.MakeReportVisible();
            }

        };
        targetReportArea.m_renderingTimeout = setTimeout(timeoutFunction, 1);
    },

    OnReportPageLoaded: function()
    {
        var reportPage = this.GetReportPage();

        this.SwapReport(reportPage);
        this.SetRegionVisibility();

        this.MakeReportVisible();
    },

    MakeReportVisible: function()
    {
        var reportPage = this.GetReportPage();

        //The ReportDivId will be null when a report hasn't been loaded.
        if (reportPage.ReportDivId)
        {
            //Start a timer.  If OnReportVisible ThreadAborts, the timer will kick-in and re-execute this code.
            //Only listen for a timeout if the Report could show.
            this.ListenForRenderingTimeout(this);
        }

        //OnReportVisible will run through all the HTMLRenderer script.  If a ThreadAbort occurs, the Timeout will fire and re-execute the logic.
        //The script updates with width/heights of items only when changing is necessary.  As the script will execute and update a certain portion of the items,
        //It will continue to make progress with each timeout until it completes within one Thread execution.
        reportPage.OnReportVisible();

        //If the timer still exists, it's no longer necessary as all the rendering logic is correctly updated.
        if (this.m_renderingTimeout)
        {
            clearTimeout(this.m_renderingTimeout);
            this.m_renderingTimeout = null;
        }

        var newContentVisibleHandler = this.get_events().getHandler("newContentVisible");
        if (newContentVisibleHandler)
            newContentVisibleHandler(this, Sys.EventArgs.Empty);

        this.ScrollToTarget(reportPage);

        reportPage.OnReportScrolled();

        // Always raise the area changed event
        var areaLoadedHandler = this.get_events().getHandler("contentChanged");
        if (areaLoadedHandler)
        {
            var eventArgs = new Sys.EventArgs();
            eventArgs.ToolBarUpdate = reportPage.get_ToolBarUpdate();

            areaLoadedHandler(this, eventArgs);
        }

        // Clear state that was saved for the report page swap so that
        // it doesn't affect the next page swap.
        this.m_previousViewportOffset = null;
        this.m_previousScrollOffset = null;
    },

    get_scrollPosition: function()
    {
        var scrollableArea = this.get_element();
        return new Sys.UI.Point(scrollableArea.scrollLeft, scrollableArea.scrollTop);
    },

    set_scrollPosition: function(scrollPoint)
    {
        var reportAreaElement = this.get_element();
        reportAreaElement.scrollTop = scrollPoint.y;
        reportAreaElement.scrollLeft = scrollPoint.x;

        this.raisePropertyChanged("scrollPosition");
    },

    // This value is not reliable until the page has loaded or the contentsChanged event has fired.
    get_contentType: function()
    {
        this.LoadNewReportAreaVisibilityState();
        return this.m_contentTypeToMakeVisibleOnNextLoad;
    },

    // ContentChanged event - fires after the contents of the report area have changed and
    // are fully loaded.
    add_contentChanged: function(handler)
    {
        this.get_events().addHandler("contentChanged", handler);
    },
    remove_contentChanged: function(handler)
    {
        this.get_events().removeHandler("contentChanged", handler);
    },

    LoadNewReportAreaVisibilityState: function()
    {
        if (this.m_userCanceled)
        {
            // this is a specific form of "canceled", m_userCanceled is true if the report got sent to the client
            // and the user decided to cancel once images were loading. In that case, we've already been given new
            // data on what is in the report area, but it's now bad data because the user canceled. So instead,
            // tell everyone the report area is empty (which it is, the cancelling forced it to be).
            this.m_contentTypeToMakeVisibleOnNextLoad = Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;
            this.m_isNewContentForNonReportContentArea = false;
        }
        else
        {
            var reportAreaVisibilityState = $get(this.ReportAreaVisibilityStateId);

            var newContentTypeAttr = reportAreaVisibilityState.attributes.getNamedItem("NewContentType");
            this.m_contentTypeToMakeVisibleOnNextLoad = eval(newContentTypeAttr.value);

            var nonReportContentAttr = reportAreaVisibilityState.attributes.getNamedItem("ForNonReportContentArea");
            this.m_isNewContentForNonReportContentArea = eval(nonReportContentAttr.value);
        }
    },

    SetRegionVisibility: function()
    {
        this.LoadNewReportAreaVisibilityState();
        this.SetSingleRegionVisibility(this.NonReportContentId, this.m_isNewContentForNonReportContentArea);
    },

    SetSingleRegionVisibility: function(regionElementId, makeVisible)
    {
        var regionElement = $get(regionElementId);
        if (makeVisible)
            regionElement.style.display = "";
        else
            regionElement.style.display = "none";
    },

    GetReportPage: function()
    {
        var reportElement = $get(this.ReportControlId);
        if (reportElement != null)
            return reportElement.control;
        else
            return null;
    },

    SwapReport: function(reportPage)
    {
        var visibleReportContentContainer = $get(this.VisibleReportContentContainerId);

        // If there is old report content
        if (visibleReportContentContainer.childNodes.length > 0)
        {
            // Save off scroll state before removing the old content
            if (this.CanScrollReportArea())
            {
                var scrollableArea = this.get_element();

                if (reportPage.AvoidScrollChange)
                {
                    this.m_previousScrollOffset = { Left: scrollableArea.scrollLeft, Top: scrollableArea.scrollTop };
                }
                else if (reportPage.PreviousViewNavigationAlignmentId != null && this.m_lastReportCellId != null)
                {
                    // Get the old target position and zoom rate
                    var previousZoom = reportPage.GetZoomFromReportCell(this.m_lastReportCellId);
                    var alignmentTargetOffset = this.CalculateElementOffset(reportPage.PreviousViewNavigationAlignmentId, previousZoom);

                    // Calculate the old offset within the viewport
                    var previousViewportOffsetLeft = alignmentTargetOffset.Left - scrollableArea.scrollLeft;
                    var previousViewportOffsetTop = alignmentTargetOffset.Top - scrollableArea.scrollTop;
                    this.m_previousViewportOffset = { Left: previousViewportOffsetLeft, Top: previousViewportOffsetTop };
                }
            }

            // Remove the old content
            var currentVisibleContent = visibleReportContentContainer.childNodes[0];
            visibleReportContentContainer.removeChild(currentVisibleContent);
        }

        // Have new content to render
        if (reportPage.ReportDivId != null)
        {
            var reportContent = $get(reportPage.ReportDivId);
            var reportParent = reportContent.parentNode;

            reportParent.removeChild(reportContent);
            if (visibleReportContentContainer.style.display == "none")
                visibleReportContentContainer.style.display = "";
            visibleReportContentContainer.appendChild(reportContent);
        }
        else if (visibleReportContentContainer.style.display == "")
            visibleReportContentContainer.style.display = "none";

    },

    ScrollToTarget: function(reportPage)
    {
        // If the report area scroll independently, scroll only that area
        if (this.CanScrollReportArea())
        {
            var newScrollTop = 0;
            var newScrollLeft = 0;
            var zoomRate = 1;

            if (reportPage.NavigationId != null)
            {
                // AvoidScrollingFromOrigin (e.g. new search page)
                if (reportPage.AvoidScrollFromOrigin)
                {
                    this.BringElementIntoView(reportPage.NavigationId, { Left: 0, Top: 0 });
                    return;
                }

                // AvoidScrolling (e.g. first search hit and it's on the current page)
                else if (this.m_previousScrollOffset != null)
                {
                    this.BringElementIntoView(reportPage.NavigationId, this.m_previousScrollOffset);
                    return;
                }

                // MaintainPosition with target / AlignedToTopLeft
                else
                {
                    // Align to top left (e.g. bookmark / docmap)
                    var targetElementOffset = this.CalculateElementOffset(reportPage.NavigationId, reportPage.GetCurrentZoomFactor());
                    newScrollTop = targetElementOffset.Top;
                    newScrollLeft = targetElementOffset.Left;

                    // MaintainPosition with target (e.g. toggle / sort) 
                    if (this.m_previousViewportOffset != null)
                    {
                        newScrollLeft -= this.m_previousViewportOffset.Left;
                        newScrollTop -= this.m_previousViewportOffset.Top;
                    }
                }
            }

            // Maintain position without target (e.g. no more search hits)
            else if (this.m_previousScrollOffset != null)
            {
                newScrollTop = this.m_previousScrollOffset.Top;
                newScrollLeft = this.m_previousScrollOffset.Left;
            }

            // Scroll to a specific pixel position (e.g. back from drillthrough, auto refresh)
            else if (reportPage.SpecificScrollPosition != null)
            {
                var scrollPosition = this._DeserializeScrollPosition(reportPage.SpecificScrollPosition);

                newScrollTop = scrollPosition.y;
                newScrollLeft = scrollPosition.x;
            }

            // Return to origin (e.g. standard page navigation)
            else
                ;

            // Scroll position can be of type float due to zoom rate
            newScrollLeft = parseInt(newScrollLeft);
            newScrollTop = parseInt(newScrollTop);
            this.set_scrollPosition(new Sys.UI.Point(newScrollLeft, newScrollTop));
        }
        else if (reportPage.NavigationId != null)
        {
            this.ScrollWebForm(reportPage.NavigationId);
        }
    },

    CanScrollReportArea: function()
    {
        var reportAreaElement = this.get_element();
        return reportAreaElement.style.overflow === "auto";
    },

    ScrollWebForm: function(navigationId)
    {
        window.location.replace("#" + navigationId);
    },

    CalculateElementOffset: function(elementId, zoomRate)
    {
        var scrollableArea = this.get_element();
        var iterator = $get(elementId);

        var totalTop = 0;
        var totalLeft = 0;

        // Sum the offsets until reaching the scroll container to find the total offset.
        // Firefox skips the visible container and goes straight to the table cell.
        while (iterator != null && iterator != scrollableArea && iterator != scrollableArea.parentNode)
        {
            totalTop += iterator.offsetTop;
            totalLeft += iterator.offsetLeft;

            iterator = iterator.offsetParent;
        }

        return { Left: totalLeft * zoomRate, Top: totalTop * zoomRate };
    },

    BringElementIntoView: function(elementId, initialScrollPosition)
    {
        var scrollableArea = this.get_element();
        var reportPage = this.GetReportPage();

        if (initialScrollPosition == null)
            initialScrollPosition = { Left: scrollableArea.scrollLeft, Top: scrollableArea.scrollTop };

        // Get the visible extents
        var visibleWidth = scrollableArea.offsetWidth;
        var visibleHeight = scrollableArea.offsetHeight;

        // Get the element position
        var elementPosition = this.CalculateElementOffset(elementId, reportPage.GetCurrentZoomFactor());

        // Assume the element is visible
        var newScrollTop = initialScrollPosition.Top;
        var newScrollLeft = initialScrollPosition.Left;

        // Check horizontal visibility
        if (newScrollLeft > elementPosition.Left || (newScrollLeft + visibleWidth) < elementPosition.Left)
        {
            // Set to centered
            newScrollLeft = elementPosition.Left - visibleWidth / 2;
        }

        // Check vertical visibility
        if (newScrollTop > elementPosition.Top || (newScrollTop + visibleHeight) < elementPosition.Top)
        {
            // Set to 1/3 down from the top
            newScrollTop = elementPosition.Top - visibleHeight / 3;
        }

        scrollableArea.scrollTop = newScrollTop;
        scrollableArea.scrollLeft = newScrollLeft;
    },

    HighlightNextSearchHit: function()
    {
        // Safety check for existence since this instance isn't called based off of an event on the report object
        var reportPage = this.GetReportPage();
        if (reportPage == null)
            return true;

        var targetId = reportPage.HighlightNextSearchHit();
        if (targetId == null)
            return false;

        if (this.CanScrollReportArea())
            this.BringElementIntoView(targetId, null);
        else
            this.ScrollWebForm(targetId);

        return true;
    },

    get_zoomLevel: function()
    {
        var reportPage = this.GetReportPage();
        if (reportPage != null)
            return reportPage.get_zoomLevel();
        else
            return 100;
    },

    set_zoomLevel: function(zoomValue)
    {
        // Safety check for existence since this instance isn't called based off of an event on the report object
        var reportPage = this.GetReportPage();
        if (reportPage != null)
            reportPage.set_zoomLevel(zoomValue);
    },

    OnScroll: function()
    {
        // FixedHeaders
        var reportPage = this.GetReportPage();
        if (reportPage)
        {
            reportPage.OnScroll();
        }

        // Keep track of the scroll position for the server control
        var serializedScrollPos = this._SerializeScrollPosition(this.get_scrollPosition());
        var scrollHiddenField = $get(this.ScrollPositionId);
        scrollHiddenField.value = serializedScrollPos;

        this.raisePropertyChanged("scrollPosition");
    },

    _OnUserCanceled: function()
    {
        this.m_userCanceled = true;
        
        var reportPage = this.GetReportPage();
        if(reportPage)
            reportPage._OnUserCanceled();
    },

    _DeserializeScrollPosition: function(serializedValue)
    {
        var top = 0;
        var left = 0;

        // Split the string
        var values = serializedValue.split(" ");
        if (values.length == 2)
        {
            // Parse the individual values as ints

            var i = parseInt(values[0], 10);
            if (!isNaN(i))
                left = i;

            i = parseInt(values[1], 10);
            if (!isNaN(i))
                top = i;
        }

        return new Sys.UI.Point(left, top);
    },

    _SerializeScrollPosition: function(scrollPoint)
    {
        return scrollPoint.x + " " + scrollPoint.y;
    },

    EnableDisableInput: function(shouldEnable)
    {
        var reportPage = this.GetReportPage();
        if (reportPage)
            reportPage.EnableDisableInput(shouldEnable);
    },

    add_newContentVisible: function (handler)
    {
        this.get_events().addHandler("newContentVisible", handler);
    },

    remove_newContentVisible: function (handler)
    {
        this.get_events().removeHandler("newContentVisible", handler);
    }
}

Microsoft.Reporting.WebFormsClient._ReportArea.registerClass("Microsoft.Reporting.WebFormsClient._ReportArea", Sys.UI.Control);

Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget = function(element)
{
    Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.initializeBase(this, [element]);

    this.PostBackForAsyncLoad = null;
    this.m_onAppLoadDelegate = Function.createDelegate(this, this.OnAppLoad);
    this.m_asyncLoadDelegate = Function.createDelegate(this, this.TriggerPostBack);
    this.m_beginAsyncLoadDelegate = Function.createDelegate(this, this.TryBeginTriggerPostBack);
    this.m_postBackTriggered = false;
}

Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.prototype =
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.callBaseMethod(this, "initialize");

        // Ensures that only one report viewer on the page causes a postback for async rendering.
        // Otherwise, multiple postback requests will be initiated and aborted if multiple async viewers
        // are on a single webform.
        if (!Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected)
        {
            Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected = true;

            Sys.Application.add_load(this.m_onAppLoadDelegate);
        }
    },

    dispose : function()
    {
        if (this.m_asyncLoadDelegate != null)
        {
            Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected = false;

            delete this.m_asyncLoadDelegate;
            this.m_asyncLoadDelegate = null;
        }

        if (this.m_onAppLoadDelegate != null)
        {
            Sys.Application.remove_load(this.m_onAppLoadDelegate);

            delete this.m_onAppLoadDelegate;
            this.m_onAppLoadDelegate = null;
        }

        if (this.m_beginAsyncLoadDelegate != null)
        {
            _$RVReportAreaAsyncLoadIsReadyTracker.remove_isReadyChanged(this.m_beginAsyncLoadDelegate);

            delete this.m_beginAsyncLoadDelegate;
            this.m_beginAsyncLoadDelegate = null;
        }

        Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.callBaseMethod(this, "dispose");
    },

    OnAppLoad : function()
    {
        if (_$RVReportAreaAsyncLoadIsReadyTracker.getIsReady())
        {
            this.TryBeginTriggerPostBack();
        }
        else
        {
            _$RVReportAreaAsyncLoadIsReadyTracker.add_isReadyChanged(this.m_beginAsyncLoadDelegate);
        }
    },

    TryBeginTriggerPostBack : function()
    {
        if (!this.m_postBackTriggered)
        {
            // Call async load on a timer to ensure that the entire Sys.Application.load event is executed
            // before triggering another postback.  During async postbacks, initialize gets called in its
            // own setTimeout, so this timer can't be fired until actually in the Sys.Application.load event.
            // Additional note: We are also waiting on the window.onload event and
            // queueing the delegate in the dispatcher is critical to allowing the other window.onload 
            // event handlers to execute completely.
            setTimeout(this.m_asyncLoadDelegate, 0);
        }
    },

    TriggerPostBack : function()
    {
        // Ensure only one async load target caused a postback.  Dispose should take care of this, but
        // check for safety in case of errors on the client.
        if (!this.m_postBackTriggered)
        {
            var isInAsyncPostBack = false;
            if (Sys.WebForms)
            {
                var pageRequestManager = Sys.WebForms.PageRequestManager.getInstance();
                isInAsyncPostBack = pageRequestManager.get_isInAsyncPostBack();
            }

            // Ensure nothing else caused an async postback already
            if (!isInAsyncPostBack)
            {
                this.PostBackForAsyncLoad();
                this.m_postBackTriggered = true;
                Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected = false;
            }
        }
    }
}

Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.registerClass("Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget", Sys.UI.Control);

// The purpose of this class is to track the load state of the page.  It will notify the ReportArea when it 
// can perform the postback to fetch the report data.  We track ready state by looking for Sys.Application.load
// and also window.onload.
Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker = function()
{
    Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker.initializeBase(this);

    this.m_appLoaded = false;
    this.m_windowLoaded = false;
    this.m_appLoadDelegate = Function.createDelegate(this, this.onAppLoad);
    this.m_windowLoadDelegate = Function.createDelegate(this, this.onWindowLoad);
}

Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker.prototype =
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker.callBaseMethod(this, "initialize");

        Sys.Application.add_load(this.m_appLoadDelegate);

        if (window.addEventListener)
            window.addEventListener("load", this.m_windowLoadDelegate, true);
        else
            window.attachEvent("onload", this.m_windowLoadDelegate);
    },
    
    getIsReady : function()
    {
        return this.m_appLoaded && this.m_windowLoaded;
    },

    tryRaiseIsReadyStateChanged : function()
    {
        if (this.getIsReady())
        {
            var readyStateChangedHandler = this.get_events().getHandler("isReadyStateChanged");
            if (readyStateChangedHandler)
            {
                var eventArgs = new Sys.EventArgs();
                eventArgs.isReady = true;
                readyStateChangedHandler(this, eventArgs);
            }
        }
    },

    onAppLoad : function()
    {
        this.m_appLoaded = true;

        this.tryRaiseIsReadyStateChanged();

        Sys.Application.remove_load(this.m_appLoadDelegate);
    },

    onWindowLoad : function()
    {
        this.m_windowLoaded = true;

        this.tryRaiseIsReadyStateChanged();

        if (window.removeEventListener)
            window.removeEventListener("load", this.m_windowLoadDelegate, true);
        else
            window.detachEvent("onload", this.m_windowLoadDelegate);
    },

    add_isReadyChanged : function(handler)
    {
        this.get_events().addHandler("isReadyStateChanged", handler);
    },

    remove_isReadyChanged : function(handler)
    {
        this.get_events().removeHandler("isReadyStateChanged", handler);
    }
}

Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker.registerClass("Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker", Sys.Component);

var _$RVReportAreaAsyncLoadIsReadyTracker = $create(Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadIsReadyTracker);// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._ReportPage = function(element)
{
    Microsoft.Reporting.WebFormsClient._ReportPage.initializeBase(this, [element]);

    // Script methods to invoke sync or async postbacks for interactivity
    this.TriggerSyncInteractivity = null;
    this.TriggerAsyncInteractivity = null;
    this.InteractivityMode = null;

    // Hidden fields to store interactivity info during the postback
    this.ActionTypeId = null;
    this.ActionParamId = null;

    this.SearchHitPrefix = null;
    this.m_nextSearchHit = 1;

    this.NavigationId = null;

    // MaintainPosition
    this.PreviousViewNavigationAlignmentId = null; // Try to align this.NavigationId to this id from the old page.

    // AvoidScrolling
    this.AvoidScrollChange = false;
    this.AvoidScrollFromOrigin = false;

    // Specific position scrolling
    this.SpecificScrollPosition = null;

    this.HiddenZoomLevelId = null;
    this.LoadMessage = null;

    this.ReportDivId = null;
    this.ReportCellId = null;
    this.ScrollableContainerId = null;

    this.m_allContentLoaded = false;
    this.m_loadDelegate = Function.createDelegate(this, this._PollForAllContentLoaded);

    this.ReportStyles = null;
    this.ReportPageStyles = null;
    this.StyleElementId = null;

    this.PrefixId = null;

    this.ScrollScript = null;
    this.m_fixedHeader = null;

    this.m_executingAction = null;
    this.m_toolbarUpdate = null;

    this.ConstFullPage = "FullPage";
    this.ConstPageWidth = "PageWidth";

    this.m_userCanceled = false;
}

Microsoft.Reporting.WebFormsClient._ReportPage.prototype =
{
    initialize: function ()
    {
        Microsoft.Reporting.WebFormsClient._ReportPage.callBaseMethod(this, "initialize");

        // Don't update the DOM until the load event (causes a race condition in Firefox
        // with hash based scrolling between the location.replace and the browser page update).
        Sys.Application.add_load(this.m_loadDelegate);
    },

    dispose: function ()
    {
        Sys.Application.remove_load(this.m_loadDelegate);
        delete this.m_loadDelegate;

        Microsoft.Reporting.WebFormsClient._ReportPage.callBaseMethod(this, "dispose");
    },

    // Custom accessor for complex object type (array)
    set_ToolBarUpdate: function (value) { this.m_toolbarUpdate = value; },
    get_ToolBarUpdate: function () { return this.m_toolbarUpdate; },

    // AllContentLoaded event - indicates that all content is loaded (may be none if there is no actual report page)
    add_allContentLoaded: function (handler)
    {
        this.get_events().addHandler("allContentLoaded", handler);
    },
    remove_allContentLoaded: function (handler)
    {
        this.get_events().removeHandler("allContentLoaded", handler);
    },

    IsLoading: function ()
    {
        return !this.m_allContentLoaded;
    },

    _OnUserCanceled: function ()
    {
        this.m_userCanceled = true;
    },

    _PollForAllContentLoaded: function ()
    {
        if (this.m_userCanceled)
        {
            // user has decided to cancel loading this report, so force the browsers to stop loading the images
            if (this.ReportDivId)
            {
                var reportDiv = $get(this.ReportDivId);

                if (reportDiv)
                {
                    // this will force IE and FireFox to stop loading all
                    // images from the reportDiv on down
                    reportDiv.innerHTML = "";
                }
            }

            return;
        }

        // Validate that the report content is loaded if there is report content
        if (this.ReportDivId != null)
        {
            // A report page is not loaded until all of the images are
            var reportDiv = $get(this.ReportDivId);

            // It's possible for the user to cause postbacks so rapidly that this method
            // is being called against the nth postback while the nth+1's ReportDiv has been
            // loaded. This will lead to a null ref exception against reportDiv, as this
            // code is trying to load a ReportDiv that no longer exists.
            // This happens very rarely, and only under ideal conditions when postbacks
            // can be triggered very rapidly. But still checking if we actually got a report div
            // here just to be safe.
            if (reportDiv)
            {
                var images = reportDiv.getElementsByTagName("IMG");

                for (var i = 0; i < images.length; i++)
                {
                    var img = images[i];
                    if (!img.complete && !img.errored)
                    {
                        setTimeout(Function.createDelegate(this, this._PollForAllContentLoaded), 250);
                        return;
                    }
                }
            }
        }

        this._OnAllContentLoaded();
    },

    _OnAllContentLoaded: function ()
    {
        if (this.m_allContentLoaded)
            return;
        this.m_allContentLoaded = true;

        // Raise content changed event
        var handler = this.get_events().getHandler("allContentLoaded");
        if (handler)
            handler(this);
    },

    OnReportVisible: function ()
    {
        this._OutputStyleStream();
        this._UpdateRenderer();
        this._ApplyZoom(this.get_zoomLevel());
    },

    _OutputStyleStream: function ()
    {
        var headElementsCollection = document.getElementsByTagName("HEAD");
        var headElement = null;

        // Ensure the HEAD element exists.  If not, create one.
        if (headElementsCollection.length == 0)
        {
            headElement = document.createElement("HEAD");
            document.documentElement.insertBefore(headElement, document.documentElement.firstChild);
        }
        else
            headElement = headElementsCollection[0];

        var oldStyleElement = document.getElementById(this.StyleElementId);

        // Remove the current STYLE element, if it already exists.
        if (oldStyleElement != null)
            headElement.removeChild(oldStyleElement);

        if (this.ReportDivId)
        {
            var reportDiv = $get(this.ReportDivId);
            var pageStyleContainerId = reportDiv.parentNode.id;
            if (pageStyleContainerId)
            {
                var pageStyles = this.ReportPageStyles;
                if (!pageStyles)
                    pageStyles = "";
                var pageStyle = "#" + pageStyleContainerId + " { " + pageStyles + "}";
                if (this.ReportStyles)
                    this.ReportStyles += pageStyle;
                else
                    this.ReportStyles = pageStyle;

                // When the viewer had an iFrame,
                // fonts would fall back to Times New Roman as that is the browser default. 
                // Now that we render as part of the page, they fall back to whatever
                // is defind in the stylesheet for the page, in the case of
                // ReportManager/Server, that is verdana. We want to maintain
                // falling back to Times New Roman, so inject that font style here
                // if an element in the report specifies a font that can't be found,
                // the browser will work up the parent chain and get here to find TNR
                this.ReportStyles += " #" + this.ReportDivId + ", #" + this.ReportDivId + " TABLE { font-family: Times New Roman; }";
            }
        }

        // If we have any styles, create a STYLE element
        // using the styles and place it in the page head.
        if (this.ReportStyles != null)
        {
            var newStyleElement = document.createElement("STYLE");
            newStyleElement.type = "text/css";
            newStyleElement.id = this.StyleElementId;

            if (newStyleElement.styleSheet != null)
                newStyleElement.styleSheet.cssText = this.ReportStyles;
            else
                newStyleElement.appendChild(document.createTextNode(this.ReportStyles));

            headElement.appendChild(newStyleElement);
        }

    },

    OnReportScrolled: function ()
    {
        if (this.LoadMessage != null)
            alert(this.LoadMessage);
    },

    InvokeReportAction: function (actionType, actionParam)
    {
        if (!this._IsInputDisabled())
        {
            // Save interactivity info for postback
            $get(this.ActionTypeId).value = actionType;
            $get(this.ActionParamId).value = this._TranslateAction(actionType, actionParam);

            if (this.InteractivityMode === "AlwaysSynchronous" ||
                (this.InteractivityMode === "SynchronousOnDrillthrough" && actionType === "Drillthrough"))
            {
                this.TriggerSyncInteractivity();
            }
            else
                this.TriggerAsyncInteractivity();
        }
    },

    HighlightNextSearchHit: function ()
    {
        if (this.SearchHitPrefix == null)
            return null;

        // Unhighlight previous hit, if any.
        if (this.m_nextSearchHit > 0)
        {
            var name = this.SearchHitPrefix + (this.m_nextSearchHit - 1);
            var hitElem = $get(name);
            var count = 0;
            // Clean up the background for a find across multiple textRuns
            while (hitElem != null)
            {
                hitElem.style.backgroundColor = "";
                hitElem.style.color = "";
                hitElem = $get(name + "_" + (++count));
            }
        }

        // Highlight current hit and navigate to it.
        var name = this.SearchHitPrefix + (this.m_nextSearchHit);
        var hitElem = $get(name);
        if (hitElem == null)
            return null;
        var count = 0;
        // Clean up the background for a find across multiple textRuns
        while (hitElem != null)
        {
            hitElem.style.backgroundColor = "highlight";
            hitElem.style.color = "highlighttext";
            hitElem = $get(name + "_" + (++count));
        }

        this.m_nextSearchHit++;

        // Return the navigation target
        return name;
    },

    _ApplyZoom: function (zoomValue)
    {
        // Get the report cell
        if (this.ReportCellId == null)
            return;
        var reportCell = $get(this.ReportCellId);

        if ((zoomValue != this.ConstPageWidth) && (zoomValue != this.ConstFullPage))
            reportCell.style.zoom = zoomValue + "%";
        else
        {
            var scrollContainer = $get(this.ScrollableContainerId);
            if (scrollContainer == null || scrollContainer.style.overflow != "auto")
                return;

            if (zoomValue != this.ConstPageWidth)
            {
                if ((reportCell.offsetWidth * scrollContainer.offsetHeight) < (reportCell.offsetHeight * scrollContainer.offsetWidth))
                    this._ApplyCalculatedZoom(reportCell, scrollContainer.offsetHeight, reportCell.offsetHeight);
                else
                    this._ApplyCalculatedZoom(reportCell, scrollContainer.offsetWidth, reportCell.offsetWidth);
            }
            else
            {
                var vbar = scrollContainer.offsetHeight != scrollContainer.clientHeight;
                var proceed = (reportCell.offsetWidth > 0);
                for (var iter = 0; (iter <= 1) & proceed; ++iter)
                {
                    zoomValue = this._ApplyCalculatedZoom(reportCell, scrollContainer.clientWidth, reportCell.offsetWidth);
                    proceed = vbar != ((reportCell.offsetHeight * zoomValue) > scrollContainer.offsetHeight);
                }
            }
        }

        //Recalc imageconsolidation for IE7.  
        //IE7 standards uses absolutely positioned images that need to scale with zoom.
        //IE7/8 quirks and IE8 standards automatically scale the images.
        if (Microsoft_ReportingServices_HTMLRenderer_ScaleImageUpdateZoom)
        {
            if (_$RVCommon.isPreIE8StandardsMode())
            {
                var fitProp = new Microsoft_ReportingServices_HTMLRenderer_FitProportional();
                fitProp.ResizeImages(this.ReportDivId, this.ReportCellId);
                Microsoft_ReportingServices_HTMLRenderer_ScaleImageUpdateZoom(this.PrefixId, this.ReportDivId, this.ReportCellId);
            }
        }

        this.OnScroll();
    },

    // Set a zoom value that is calculated based on the report width/height
    _ApplyCalculatedZoom: function (reportCell, div, rep)
    {
        if (rep <= 0)
            return 1.0;
        var z = (div - 1) / rep;
        reportCell.style.zoom = z;
        return z;
    },

    // Gets the actual current zoom value as a fraction (1.0, 2.0, etc) regardless of whether
    // the zoom mode is percentage or FullPage/PageWidth
    GetCurrentZoomFactor: function ()
    {
        return this.GetZoomFromReportCell(this.ReportCellId);
    },

    GetZoomFromReportCell: function (cellId)
    {
        var reportCell = $get(cellId);

        // If very rapid postbacks are occuring, it's possible
        // to end up in a situation where cellId refers to an element
        // that no longer exists (it's been replaced with new content and
        // the script descriptors have not ran to update the client side objects)
        // so checking if reportCell is null before proceeding here.
        if (reportCell)
        {
            var zoom = reportCell.style.zoom;
            if (zoom == null) //Must check for null, because in firefox zoom is not a supported css property and is not set.
            {
                return 1.0;
            }
            if (typeof zoom === "number")
            {
                return zoom;
            }
            var zoomStr = String(zoom); 
            if (zoomStr != "")
            {
            	if (zoomStr.charAt(zoomStr.length - 1) === "%")
                {
                    zoomStr = zoomStr.substr(0, zoomStr.length - 1); // Remove % sign
                    return zoomStr / 100.0;
                }
                var zoomFloat = parseFloat(zoomStr);
                return zoomFloat != null ? zoomFloat : 1.0;
            }
        }

        return 1.0;
    },

    get_zoomLevel: function ()
    {
        var hiddenZoomLevelElement = $get(this.HiddenZoomLevelId);
        return hiddenZoomLevelElement.value;
    },

    set_zoomLevel: function (newZoomLevel)
    {
        // Validate newZoomLevel
        if (newZoomLevel != this.ConstPageWidth && newZoomLevel != this.ConstFullPage)
        {
            // Validate percentage zoom
            var newZoomAsInt = parseInt(newZoomLevel, 10)
            if (isNaN(newZoomAsInt) || newZoomAsInt <= 0)
                throw Error.argumentOutOfRange("zoomLevel", newZoomLevel, "The zoom level must be a positive integer or '" + this.ConstPageWidth + "' or '" + this.ConstFullPage + "'.");
            else
                newZoomLevel = newZoomAsInt; // Normalize the value
        }

        // Apply the zoom value
        this._ApplyZoom(newZoomLevel);

        // Save the value for the postback
        var hiddenZoomLevelElement = $get(this.HiddenZoomLevelId);
        hiddenZoomLevelElement.value = newZoomLevel;
    },

    //FitProportional
    _UpdateRenderer: function ()
    {
        if (this.ReportDivId)
        {
            var fitProp = new Microsoft_ReportingServices_HTMLRenderer_FitProportional();
            fitProp.ResizeImages(this.ReportDivId, this.ReportCellId);

            if (Microsoft_ReportingServices_HTMLRenderer_ScaleImageConsolidation)
                Microsoft_ReportingServices_HTMLRenderer_ScaleImageConsolidation(this.PrefixId, this.ReportDivId, this.ReportCellId);

            if (Microsoft_ReportingServices_HTMLRenderer_ScaleImageForFit)
                Microsoft_ReportingServices_HTMLRenderer_ScaleImageForFit(this.PrefixId, this.ReportDivId);

            if (Microsoft_ReportingServices_HTMLRenderer_GrowRectangles)
                Microsoft_ReportingServices_HTMLRenderer_GrowRectangles(this.PrefixId, this.ReportDivId);

            if (Microsoft_ReportingServices_HTMLRenderer_FitVertText)
                Microsoft_ReportingServices_HTMLRenderer_FitVertText(this.PrefixId, this.ReportDivId);
        }
    },

    OnScroll: function ()
    {
        if (this.ScrollScript)
        {
            var firstTime = !this.m_fixedHeader;
            if (firstTime)
            {
                this.m_fixedHeader = new Microsoft_ReportingServices_HTMLRenderer_FixedHeader(this.ReportDivId, this.ReportCellId,
                    $get(this.ReportDivId).parentNode.id, this.PrefixId);
            }
            this.ScrollScript(firstTime);
        }
    },

    EnableDisableInput: function (shouldEnable)
    {
        if (shouldEnable)
            this.m_executingAction = null;
        else
            this.m_executingAction = true;
    },

    _IsInputDisabled: function ()
    {
        return this.m_executingAction == true;
    },

    _TranslateAction: function (actionType, actionParam)
    {
        var completeActionParam;
        if (actionType == "Sort")
        {
            if (window.event && window.event.shiftKey)
                completeActionParam = actionParam + "_T";
            else
                completeActionParam = actionParam + "_F";
        }
        else
            completeActionParam = actionParam;

        return completeActionParam;
    }
}

Microsoft.Reporting.WebFormsClient._ReportPage.registerClass("Microsoft.Reporting.WebFormsClient._ReportPage", Sys.UI.Control);

// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._SessionKeepAlive = function ()
{
    Microsoft.Reporting.WebFormsClient._SessionKeepAlive.initializeBase(this);

    this.KeepAliveUrl = null;
    this.KeepAliveBody = null;
    this.KeepAliveIntervalSeconds = 0;

    this.m_keepAliveTimerId = null;
    this.m_executingKeepAlive = null;

    this.m_isInitialized = false;

    this.m_onTimerIntervalDelegate = Function.createDelegate(this, this.KeepSessionsAlive);
    this.m_onKeepAliveRequestCompletedDelegate = Function.createDelegate(this, this.OnKeepAliveRequestCompleted);

    this.m_onAppLoadDelegate = Function.createDelegate(this, this.OnAppLoad);
}

Microsoft.Reporting.WebFormsClient._SessionKeepAlive.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._SessionKeepAlive.callBaseMethod(this, "initialize");

        // Need to wait until app load to avoid async calls colliding with async postback
        Sys.Application.add_load(this.m_onAppLoadDelegate);
    },

    dispose: function()
    {
        this.CancelKeepAliveTimer();

        if (this.m_executingKeepAlive != null)
            this.m_executingKeepAlive.abort();

        delete this.m_onTimerIntervalDelegate;
        this.m_onTimerIntervalDelegate = null;

        delete this.m_onKeepAliveRequestCompletedDelegate;
        this.m_onKeepAliveRequestCompletedDelegate = null;

        Sys.Application.remove_load(this.m_onAppLoadDelegate);
        delete this.m_onAppLoadDelegate;
        this.m_onAppLoadDelegate = null;

        Microsoft.Reporting.WebFormsClient._SessionKeepAlive.callBaseMethod(this, "dispose");
    },

    OnAppLoad: function()
    {
        if (this.m_isInitialized)
            return;

        if (this.KeepAliveIntervalSeconds != 0)
        {
            this.KeepSessionsAlive();
            this.m_keepAliveTimerId = setInterval(this.m_onTimerIntervalDelegate, this.KeepAliveIntervalSeconds * 1000);
        }

        this.m_isInitialized = true;
    },

    KeepSessionsAlive: function()
    {
        // Don't ping twice simultaneously
        if (this.m_executingKeepAlive != null)
            return;

        var webRequest = new Sys.Net.WebRequest();
        webRequest.set_url(this.KeepAliveUrl);
        webRequest.set_httpVerb("POST");
        if (this.KeepAliveBody != null)
        {
            webRequest.set_body(this.KeepAliveBody);
            // WebKit doesn't allow to set Content-Length explicitly due security reasons.
            // Content lenght will be determined and set based on actual body length.
            if (Sys.Browser.agent != Sys.Browser.Safari)
            {
                webRequest.get_headers()["Content-Length"] = this.KeepAliveBody.length;
            }
        }
        webRequest.add_completed(this.m_onKeepAliveRequestCompletedDelegate);

        webRequest.invoke();
        this.m_executingKeepAlive = webRequest.get_executor();
    },

    OnKeepAliveRequestCompleted: function(executor, eventArgs)
    {
        this.m_executingKeepAlive = null;

        if (executor.get_timedOut() || (executor.get_responseAvailable() && executor.get_statusCode() != 200))
        {
            this.CancelKeepAliveTimer();
        }
    },

    CancelKeepAliveTimer: function()
    {
        if (this.m_keepAliveTimerId != null)
        {
            clearTimeout(this.m_keepAliveTimerId);
            this.m_keepAliveTimerId = null;
        }
    }
}

Microsoft.Reporting.WebFormsClient._SessionKeepAlive.registerClass("Microsoft.Reporting.WebFormsClient._SessionKeepAlive", Sys.Component);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._ScriptSwitchImage = function(element)
{
    Microsoft.Reporting.WebFormsClient._ScriptSwitchImage.initializeBase(this, [element]);
    
    this.m_image1 = null;
    this.m_image2 = null;
}

Microsoft.Reporting.WebFormsClient._ScriptSwitchImage.prototype =
{
    set_Image1: function (value) { this.m_image1 = value; },
    get_Image1: function () { return this.m_image1; },
    set_Image2: function (value) { this.m_image2 = value; },
    get_Image2: function () { return this.m_image2; },

    dispose: function ()
    {
        this.m_image1 = null;
        this.m_image2 = null;
        Microsoft.Reporting.WebFormsClient._ScriptSwitchImage.callBaseMethod(this, "dispose");
    },

    ShowImage: function (shouldShowImage1)
    {
        if (this.m_image1 == null || this.m_image2 == null)
            return;

        if (shouldShowImage1)
        {
            this.m_image1.style.display = "";
            this.m_image2.style.display = "none";
        }
        else
        {
            this.m_image2.style.display = "";
            this.m_image1.style.display = "none";
        }
    },

    SetOnClickHandler: function (forImage1, handler)
    {
        var image;
        if (forImage1)
            image = this.m_image1;
        else
            image = this.m_image2;

        image.control.OnClickScript = handler;
    }
}

Microsoft.Reporting.WebFormsClient._ScriptSwitchImage.registerClass("Microsoft.Reporting.WebFormsClient._ScriptSwitchImage", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._TextButton = function(element)
{
    Microsoft.Reporting.WebFormsClient._TextButton.initializeBase(this, [element]);

    this.IsActive = false;
    this.OnClickScript = null;

    this.ActiveLinkStyle = null;
    this.DisabledLinkStyle = null;

    this.ActiveLinkColor = null;
    this.DisabledLinkColor = null;
    this.ActiveHoverLinkColor = null;
}

Microsoft.Reporting.WebFormsClient._TextButton.prototype = 
{
    initialize : function()
    {
        Microsoft.Reporting.WebFormsClient._TextButton.callBaseMethod(this, "initialize");

        $addHandlers(this.get_element(),
            { "mouseover" : this.OnMouseOver,
              "mouseout"  : this.OnMouseOut,
              "click"     : this.OnClick },
            this);

        this.OnMouseOut(null);
    },
    
    dispose : function()
    {
        $clearHandlers(this.get_element());
        
        Microsoft.Reporting.WebFormsClient._TextButton.callBaseMethod(this, "dispose");
    },
    
    OnMouseOver : function(e)
    {
        if (this.ActiveLinkStyle != null)
            return;
            
        var link = this.get_element();

        if (this.IsActive)
        {
            link.style.textDecoration = "underline";
            link.style.color = this.ActiveHoverLinkColor;
            link.style.cursor = "pointer";
        }
        else
            link.style.cursor = "default";
    },
    
    OnMouseOut : function(e)
    {
        if (this.ActiveLinkStyle != null)
            return;

        var link = this.get_element();

        if (this.IsActive)
            link.style.color = this.ActiveLinkColor;
        else
            link.style.color = this.DisabledLinkColor;
        link.style.textDecoration = "none";
    },
    
    OnClick : function(e)
    {
        if (this.OnClickScript != null && this.IsActive)
            this.OnClickScript();

        e.preventDefault();
    },
    
    SetActive : function(makeActive)
    {
        var button = this.get_element();
            
        this.IsActive = makeActive;
        
        // If using styles, update style name
        if (this.ActiveLinkStyle != null)
        {
            if (this.IsActive)
                button.className = this.ActiveLinkStyle;
            else
                button.className = this.DisabledLinkStyle;
        }
        
        this.OnMouseOut(null);
    }
}

Microsoft.Reporting.WebFormsClient._TextButton.registerClass("Microsoft.Reporting.WebFormsClient._TextButton", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._Toolbar = function (element)
{
    Microsoft.Reporting.WebFormsClient._Toolbar.initializeBase(this, [element]);

    this.m_reportViewer = null;
    this.m_onReportViewerLoadingChangedDelegate = Function.createDelegate(this, this.OnReportViewerLoadingChanged);
    this.m_onReportAreaContentChangedDelegate = Function.createDelegate(this, this.OnReportAreaContentChanged);

    // Page Nav
    this.CurrentPage = 0;
    this.TotalPages = 0;
    this.IsEstimatePageCount = true;
    this.m_currentPageTextBox = null;
    this.m_totalPagesLabel = null;
    this.m_firstPageNavButton = null;
    this.m_prevPageNavButton = null;
    this.m_nextPageNavButton = null;
    this.m_lastPageNavButton = null;
    this.InvalidPageNumberMessage = null;
    this.OnCurrentPageClick = null;

    // Drillthrough Back
    this.IsDrillthroughReport = false;
    this.m_drillBackButton = null;

    // Refresh
    this.m_refreshButton = null;
    this.m_onRefreshClickDelegate = Function.createDelegate(this, this.OnRefreshClick);

    // Zoom
    this.m_zoomDropDown = null;
    this.m_zoomSelectionChangeDelegate = Function.createDelegate(this, this.OnZoomSelectionChanged);
    this.m_externalZoomChangeDelegate = Function.createDelegate(this, this.OnZoomChangedExternal);

    // Find
    this.m_findTextBox = null;
    this.m_findButton = null;
    this.m_findNextButton = null;
    this.CanFindNext = false;
    this.FindTextBoxPollInterval = null;
    this.m_onFindTextChangeDelegate = Function.createDelegate(this, this.OnFindTextChanged);
    this.m_onFindTextFocusDelegate = Function.createDelegate(this, this.OnFindTextFocus);
    this.m_onFindTextBlurDelegate = Function.createDelegate(this, this.OnFindTextBlur);
    this.m_enableDisableFindButtonsDelegate = Function.createDelegate(this, this.CheckEnableDisableFindButtons);
    this.m_onFindClickDelegate = Function.createDelegate(this, this.OnFindClick);
    this.m_onFindNextClickDelegate = Function.createDelegate(this, this.OnFindNextClick);

    // Export
    this.m_exportButton = null;

    // Print
    this.m_printButton = null;
    this.m_onPrintClickDelegate = Function.createDelegate(this, this.OnPrintClick);

    // Atom Data Feed
    this.m_atomDataFeedButton = null;
    this.m_onAtomDataFeedClickDelegate = Function.createDelegate(this, this.OnAtomDataFeedClick);

    this.m_isFirstEnable = true;
}

Microsoft.Reporting.WebFormsClient._Toolbar.prototype =
{
    initialize: function ()
    {
        Microsoft.Reporting.WebFormsClient._Toolbar.callBaseMethod(this, "initialize");

        // Assumes viewer was created first
        this.m_reportViewer.add_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
        this.m_reportViewer.add_propertyChanged(this.m_onReportAreaContentChangedDelegate);

        // Don't postback the zoom dropdown.  It isn't used on the server and can cause event
        // validation to fail in some cases, such as when a custom value is added to the dropdown
        // on the client.
        if (this.m_zoomDropDown != null)
            this.m_zoomDropDown.name = null;
    },

    dispose: function ()
    {
        if (this.FindTextBoxPollInterval != null)
        {
            clearInterval(this.FindTextBoxPollInterval);
        }

        Microsoft.Reporting.WebFormsClient._Toolbar.callBaseMethod(this, "dispose");

        // Disconnect from the report viewer
        if (this.m_reportViewer != null)
        {
            this.m_reportViewer.remove_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
            this.m_reportViewer.remove_propertyChanged(this.m_onReportAreaContentChangedDelegate);
            this.m_reportViewer.remove_propertyChanged(this.m_externalZoomChangeDelegate);
        }

        if (this.m_currentPageTextBox != null)
        {
            $clearHandlers(this.m_currentPageTextBox);

            this.m_currentPageTextBox = null;
            this.m_totalPagesLabel = null;
            this.m_firstPageNavButton = null;
            this.m_prevPageNavButton = null;
            this.m_nextPageNavButton = null;
            this.m_lastPageNavButton = null;
        }

        if (this.m_findTextBox != null)
        {
            $clearHandlers(this.m_findTextBox);

            this.m_findTextBox = null;
            this.m_findButton = null;
            this.m_findNextButton = null;
        }

        this.m_drillBackButton = null;
        this.m_zoomDropDown = null;
        this.m_refreshButton = null;
        this.m_exportButton = null;
        this.m_printButton = null;
        this.m_atomDataFeedButton = null;

        // Delete all the delegates
        if (this.m_onFindTextChangeDelegate != null)
        {
            delete this.m_onFindTextChangeDelegate;
            this.m_onFindTextChangeDelegate = null;

            delete this.m_onFindTextFocusDelegate;
            this.m_onFindTextFocusDelegate = null;

            delete this.m_onFindTextBlurDelegate;
            this.m_onFindTextBlurDelegate = null;

            delete this.m_enableDisableFindButtonsDelegate;
            this.m_enableDisableFindButtonsDelegate = null;

            delete this.m_onFindClickDelegate;
            this.m_onFindClickDelegate = null;

            delete this.m_onFindNextClickDelegate;
            this.m_onFindNextClickDelegate = null;

            delete this.m_zoomSelectionChangeDelegate;
            this.m_zoomSelectionChangeDelegate = null;

            delete this.m_externalZoomChangeDelegate;
            this.m_externalZoomChangeDelegate = null;

            delete this.m_onPrintClickDelegate;
            this.m_onPrintClickDelegate = null;

            delete this.m_onAtomDataFeedClickDelegate;
            this.m_onAtomDataFeedClickDelegate = null;

            delete this.m_onRefreshClickDelegate;
            this.m_onRefreshClickDelegate = null;

            delete this.m_onReportViewerLoadingChangedDelegate;
            this.m_onReportViewerLoadingChangedDelegate = null;

            delete this.m_onReportAreaContentChangedDelegate;
            this.m_onReportAreaContentChangedDelegate = null;
        }
    },

    set_CurrentPageTextBox: function (value) { this.m_currentPageTextBox = value; },
    get_CurrentPageTextBox: function () { return this.m_currentPageTextBox; },
    set_TotalPagesLabel: function (value) { this.m_totalPagesLabel = value; },
    get_TotalPagesLabel: function () { return this.m_totalPagesLabel; },
    set_FirstPageNavButton: function (value) { this.m_firstPageNavButton = value; },
    get_FirstPageNavButton: function () { return this.m_firstPageNavButton; },
    set_PrevPageNavButton: function (value) { this.m_prevPageNavButton = value; },
    get_PrevPageNavButton: function () { return this.m_prevPageNavButton; },
    set_NextPageNavButton: function (value) { this.m_nextPageNavButton = value; },
    get_NextPageNavButton: function () { return this.m_nextPageNavButton; },
    set_LastPageNavButton: function (value) { this.m_lastPageNavButton = value; },
    get_LastPageNavButton: function () { return this.m_lastPageNavButton; },

    set_FindTextBox: function (value) { this.m_findTextBox = value; },
    get_FindTextBox: function () { return this.m_findTextBox; },
    set_FindButton: function (value) { this.m_findButton = value; },
    get_FindButton: function () { return this.m_findButton; },
    set_FindNextButton: function (value) { this.m_findNextButton = value; },
    get_FindNextButton: function () { return this.m_findNextButton; },

    set_ZoomDropDown: function (value) { this.m_zoomDropDown = value; },
    get_ZoomDropDown: function () { return this.m_zoomDropDown; },
    set_RefreshButton: function (value) { this.m_refreshButton = value; },
    get_RefreshButton: function () { return this.m_refreshButton; },
    set_DrillBackButton: function (value) { this.m_drillBackButton = value; },
    get_DrillBackButton: function () { return this.m_drillBackButton; },
    set_ExportButton: function (value) { this.m_exportButton = value; },
    get_ExportButton: function () { return this.m_exportButton; },
    set_PrintButton: function (value) { this.m_printButton = value; },
    get_PrintButton: function () { return this.m_printButton; },
    set_AtomDataFeedButton: function (value) { this.m_atomDataFeedButton = value; },
    get_AtomDataFeedButton: function () { return this.m_atomDataFeedButton; },

    set_ReportViewer: function (value)
    {
        this.m_reportViewer = value;
    },

    ConnectEventHandlers: function ()
    {
        // PageNav
        if (this.m_currentPageTextBox != null)
        {
            $addHandlers(this.m_currentPageTextBox,
                { "keypress": this.OnCurrentPageKeyPress },
                this);
        }

        // Find
        if (this.m_findTextBox != null)
        {
            // onpropertychange is an IE only event, if it does not exist we use polling on onfocus instead.
            if (typeof this.m_findTextBox.onpropertychange != 'undefined')
            {
                this.m_findTextBox.onpropertychange = this.m_onFindTextChangeDelegate;
            }
            else
            {
                this.m_findTextBox.onfocus = this.m_onFindTextFocusDelegate;
                this.m_findTextBox.onblur = this.m_onFindTextBlurDelegate;
            }

            $addHandlers(this.m_findTextBox,
                { "keypress": this.OnFindTextKeyPress },
                this);

            this.m_findButton.control.OnClickScript = this.m_onFindClickDelegate;

            this.m_findNextButton.control.OnClickScript = this.m_onFindNextClickDelegate;
        }

        // Zoom
        if (this.m_zoomDropDown != null)
        {
            this.m_zoomDropDown.onchange = this.m_zoomSelectionChangeDelegate;

            this.m_reportViewer.add_propertyChanged(this.m_externalZoomChangeDelegate);
        }

        // Print
        if (this.m_printButton != null)
            this.m_printButton.control.SetOnClickHandler(true, this.m_onPrintClickDelegate);

        // Atom Data Feed
        if (this.m_atomDataFeedButton != null)
            this.m_atomDataFeedButton.control.SetOnClickHandler(true, this.m_onAtomDataFeedClickDelegate);

        // Refresh
        if (this.m_refreshButton != null)
            this.m_refreshButton.control.SetOnClickHandler(true, this.m_onRefreshClickDelegate);
    },

    OnReportViewerLoadingChanged: function (sender, e)
    {
        if (e.get_propertyName() == "isLoading")
        {
            var isLoading = this.m_reportViewer.get_isLoading();

            this.EnableDisable(!isLoading);
        }
    },

    OnReportAreaContentChanged: function (sender, e)
    {
        if (e.get_propertyName() == "reportAreaContentType")
        {
            var updateProperties = this.m_reportViewer._get_toolBarUpdate();
            if (updateProperties != null)
                this.UpdateForNewReportPage(updateProperties);
        }
    },

    EnableDisable: function (forEnable)
    {
        if (forEnable)
        {
            if (this.m_isFirstEnable)
            {
                this.ConnectEventHandlers();
                this.m_isFirstEnable = false;
            }
        }

        // Enable/Disable UI elements.  If enabling and about to trigger a postback
        // (which would just disable things again), skip the enable.
        if (!forEnable || !Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected)
        {
            var reportAreaContentType = Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;
            if (forEnable)
            {
                // Only get the content type if we are enabling the toolbar.  Otherwise it isn't available yet.
                reportAreaContentType = this.m_reportViewer.get_reportAreaContentType();
            }
            var isDisplayingReportPage = reportAreaContentType == Microsoft.Reporting.WebFormsClient.ReportAreaContent.ReportPage;

            // this is a rather implicit way to determine if the user canceled a report rendering
            // if the viewer is no longer loading and the viewer has no content, then the only way that is possible is if the user
            // canceled the request.
            var canceled = !this.m_reportViewer.get_isLoading() && reportAreaContentType == Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;

            // Drillthrough Back
            // it should be enabled if this is a drillthrough report and the whole toolbar is enabled or the viewer is in the canceled state
            var enableBack =
                (forEnable ||
                canceled) &&
                this.IsDrillthroughReport;
            this.EnableDisableImage(this.m_drillBackButton, enableBack);

            // Refresh
            // should always be enabled if the user has put the viewer in a canceled state
            var enableRefresh =
                (forEnable &&
                (isDisplayingReportPage ||
                 reportAreaContentType == Microsoft.Reporting.WebFormsClient.ReportAreaContent.Error)) ||
                 canceled;
            this.EnableDisableImage(this.m_refreshButton, enableRefresh);

            // Page Nav
            var canPageNav = reportAreaContentType == Microsoft.Reporting.WebFormsClient.ReportAreaContent.ReportPage;
            var canPageNavBackward = canPageNav && this.CurrentPage > 1;
            var canPageNavForward = canPageNav && (this.CurrentPage < this.TotalPages || this.IsEstimatePageCount);
            this.EnableDisableWebControl(this.m_currentPageTextBox, isDisplayingReportPage);
            this.EnableDisableImage(this.m_firstPageNavButton, isDisplayingReportPage && canPageNavBackward);
            this.EnableDisableImage(this.m_prevPageNavButton, isDisplayingReportPage && canPageNavBackward);
            this.EnableDisableImage(this.m_nextPageNavButton, isDisplayingReportPage && canPageNavForward);
            this.EnableDisableImage(this.m_lastPageNavButton, isDisplayingReportPage && canPageNavForward);

            // Zoom
            this.EnableDisableWebControl(this.m_zoomDropDown, isDisplayingReportPage);

            // Find
            this.EnableDisableWebControl(this.m_findTextBox, isDisplayingReportPage);
            this.EnableDisableFindButtons(isDisplayingReportPage);

            // Export
            this.EnableDisableExportButton(isDisplayingReportPage);

            // Print
            this.EnableDisableImage(this.m_printButton, isDisplayingReportPage);

            // Atom Data Feed
            this.EnableDisableImage(this.m_atomDataFeedButton, isDisplayingReportPage);
        }
    },

    UpdateForNewReportPage: function (updateProperties)
    {
        // Store the new property values
        this.CurrentPage = updateProperties.CurrentPage;
        this.TotalPages = updateProperties.TotalPages;
        this.IsEstimatePageCount = updateProperties.IsEstimatePageCount;

        // Update the current page UI
        if (this.m_currentPageTextBox != null)
            this.m_currentPageTextBox.value = this.CurrentPage;

        // Update the total pages UI
        if (this.m_totalPagesLabel != null)
            this.m_totalPagesLabel.innerHTML = updateProperties.TotalPagesString;

        // Assume zoom level may have changed.  Re-read it from the viewer object
        this.SetUIToCurrentZoomLevel();

        // Update the search string
        if (this.m_findTextBox != null)
            this.m_findTextBox.value = updateProperties.SearchText;

        this.CanFindNext = updateProperties.CanFindNext;

        this.EnableDisable(true);
    },

    EnableDisableFindButtons: function (forEnable)
    {
        if (this.m_findTextBox == null)
            return;

        var findBox = this.m_findTextBox;
        var findBoxHasText = findBox != null && findBox.value != null && findBox.value != "";

        this.EnableDisableTextButton(this.m_findButton, forEnable && findBoxHasText);
        this.EnableDisableTextButton(this.m_findNextButton, forEnable && this.CanFindNext);
    },

    EnableDisableExportButton: function (forEnable)
    {
        this.EnableDisableTextButton(this.m_exportButton, forEnable);
    },

    EnableDisableWebControl: function (element, forEnable)
    {
        if (element != null)
            element.disabled = forEnable ? null : "disabled";
    },

    EnableDisableImage: function (element, forEnable)
    {
        if (element != null && element.control != null)
        {
            element.control.ShowImage(forEnable);
            element.disabled = forEnable ? null : "disabled";
        }
    },

    EnableDisableTextButton: function (element, forEnable)
    {
        if (element != null && element.control != null)
            element.control.SetActive(forEnable);
    },

    OnFindClick: function ()
    {
        var searchText = this.m_findTextBox.value;

        this.m_reportViewer.find(searchText);
    },

    OnFindNextClick: function ()
    {
        this.m_reportViewer.findNext();
    },

    OnFindTextChanged: function ()
    {
        if (event.propertyName == "value")
        {
            this.CanFindNext = false;
            this.EnableDisableFindButtons(true);
        }
    },

    OnFindTextFocus: function ()
    {
        this.FindTextBoxPollInterval = setInterval(this.m_enableDisableFindButtonsDelegate, 250);
    },

    OnFindTextBlur: function ()
    {
        clearInterval(this.FindTextBoxPollInterval);
        this.EnableDisableFindButtons(true);
    },

    OnFindTextKeyPress: function (e)
    {
        if (e.charCode == 10 || e.charCode == 13)
        {
            this.OnFindClick();
            e.preventDefault();
        }
    },

    OnCurrentPageKeyPress: function (e)
    {
        if (e.charCode == 10 || e.charCode == 13)
        {
            var pageNumber = parseInt(this.m_currentPageTextBox.value, 10);
            if (isNaN(pageNumber) || pageNumber < 1 || (pageNumber > this.TotalPages && !this.IsEstimatePageCount))
                alert(this.InvalidPageNumberMessage);
            else
                this.OnCurrentPageClick();

            e.preventDefault();
        }
    },

    CheckEnableDisableFindButtons: function ()
    {
        this.EnableDisableFindButtons(true);
    },

    OnZoomSelectionChanged: function ()
    {
        this.m_reportViewer.set_zoomLevel(this.m_zoomDropDown.value);
    },

    OnZoomChangedExternal: function (sender, e)
    {
        if (e.get_propertyName() == "zoomLevel")
            this.SetUIToCurrentZoomLevel();
    },

    SetUIToCurrentZoomLevel: function ()
    {
        var zoomDropDown = this.m_zoomDropDown;
        if (zoomDropDown == null)
            return;

        // Get the new zoom level
        var zoomLevel = this.m_reportViewer.get_zoomLevel();

        var options = zoomDropDown.options;

        // Find an existing option in the dropdown that matches the new zoom level
        for (var i = 0; i < options.length; i++)
        {
            if (options(i).value == zoomLevel)
            {
                if (zoomDropDown.selectedIndex != i)
                    zoomDropDown.selectedIndex = i;
                return;
            }
        }

        // Couldn't find one so this must be a custom zoom percentage.  Add a
        // new option for it and select it.
        var newOption = document.createElement("option");
        newOption.text = escape(zoomLevel) + "%";
        newOption.value = zoomLevel;
        zoomDropDown.add(newOption);
        zoomDropDown.selectedIndex = options.length - 1;
    },


    OnPrintClick: function ()
    {
        this.m_reportViewer.invokePrintDialog();
    },

    OnAtomDataFeedClick: function ()
    {
        this.m_reportViewer.exportReport("ATOM");
    },

    OnRefreshClick: function ()
    {
        this.m_reportViewer.refreshReport();
    }
}

Microsoft.Reporting.WebFormsClient._Toolbar.registerClass("Microsoft.Reporting.WebFormsClient._Toolbar", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient.ReportViewer = function()
{
    Microsoft.Reporting.WebFormsClient.ReportViewer.initializeBase(this);

    this._internalViewerId = null;
    this._needHookEvents = true;

    this._onAppLoadDelegate = Function.createDelegate(this, this._onAppLoad);
    this._onInternalViewerDisposingDelegate = Function.createDelegate(this, this._onInternalViewerDisposing);
    this._onInternalViewerLoadingDelegate = Function.createDelegate(this, this._onInternalViewerLoading);
    this._onReportAreaContentChangedDelegate = Function.createDelegate(this, this._onReportAreaContentChanged);
    this._onReportAreaNewContentVisibleDelegate = Function.createDelegate(this, this._onReportAreaNewContentVisible);
    this._onReportAreaScrollPositionChangedDelegate = Function.createDelegate(this, this._onReportAreaScrollPositionChanged);
    this._onDocMapAreaCollapseChangedDelegate = Function.createDelegate(this, this._onDocMapAreaCollapseChanged);
    this._onPromptAreaCollapseChangedDelegate = Function.createDelegate(this, this._onPromptAreaCollapseChanged);
}

Microsoft.Reporting.WebFormsClient.ReportViewer.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient.ReportViewer.callBaseMethod(this, "initialize");

        Sys.Application.add_load(this._onAppLoadDelegate);
    },

    dispose: function()
    {
        Microsoft.Reporting.WebFormsClient.ReportViewer.callBaseMethod(this, "dispose");

        if (this._onAppLoadDelegate != null)
        {
            Sys.Application.remove_load(this._onAppLoadDelegate);
            delete this._onAppLoadDelegate;
            this._onAppLoadDelegate = null;
        }

        if (this._onInternalViewerDisposingDelegate != null)
        {
            var internalViewer = this._tryGetInternalViewer();
            if (internalViewer != null)
            {
                internalViewer.remove_disposing(this._onInternalViewerDisposingDelegate);
                internalViewer.remove_propertyChanged(this._onReportAreaContentChangedDelegate);
                internalViewer.remove_propertyChanged(this._onInternalViewerLoadingDelegate);
                internalViewer.remove_propertyChanged(this._onReportAreaScrollPositionChangedDelegate);
                internalViewer.remove_reportAreaNewContentVisible(this._onReportAreaNewContentVisibleDelegate);
                internalViewer.remove_propertyChanged(this._onDocMapAreaCollapseChangedDelegate);
                internalViewer.remove_propertyChanged(this._onPromptAreaCollapseChangedDelegate);
            }

            delete this._onInternalViewerDisposingDelegate;
            this._onInternalViewerDisposingDelegate = null;

            delete this._onReportAreaContentChangedDelegate;
            this._onReportAreaContentChangedDelegate = null;

            delete this._onInternalViewerLoadingDelegate;
            this._onInternalViewerLoadingDelegate = null;

            delete this._onReportAreaScrollPositionChangedDelegate;
            this._onReportAreaScrollPositionChangedDelegate = null;

            delete this._onDocMapAreaCollapseChangedDelegate;
            this._onDocMapAreaCollapseChangedDelegate = null;

            delete this._onPromptAreaCollapseChangedDelegate;
            this._onPromptAreaCollapseChangedDelegate = null;
        }
    },

    invokePrintDialog: function()
    {
        this._ensureReportAreaHasReportPage();

        var internalViewer = this._getInternalViewer();
        return internalViewer.PrintDialog();
    },

    exportReport: function(format)
    {
        this._ensureReportAreaHasReportPage();

        var internalViewer = this._getInternalViewer();
        return internalViewer.ExportReport(format);
    },

    find: function(text)
    {
        this._ensureReportAreaHasReportPage();

        var internalViewer = this._getInternalViewer();
        return internalViewer.Find(text);
    },

    recalculateLayout: function()
    {
        var internalViewer = this._getInternalViewer();
        // this ensures recalc will get called in IE
        internalViewer.ResizeViewerReportUsingContainingElement(true);
    },

    _resetSizeToServerDefault: function()
    {
        var internalViewer = this._tryGetInternalViewer();
        if (internalViewer != null)
            internalViewer.ResetSizeToServerDefault();
    },

    findNext: function()
    {
        this._ensureReportAreaHasReportPage();

        var internalViewer = this._getInternalViewer();
        return internalViewer.FindNext();
    },

    refreshReport: function()
    {
        var reportAreaContentType = this.get_reportAreaContentType();
        var canceled = !this.get_isLoading() && reportAreaContentType == Microsoft.Reporting.WebFormsClient.ReportAreaContent.None;

        // if the user successfully canceled, then there is a report loaded in this viewer,
        // so allow them to refresh it.
        if (reportAreaContentType != Microsoft.Reporting.WebFormsClient.ReportAreaContent.ReportPage &&
            reportAreaContentType != Microsoft.Reporting.WebFormsClient.ReportAreaContent.Error && !canceled)
        {
            this._throwExceptionForInvalidState();
        }

        var internalViewer = this._getInternalViewer();
        internalViewer.RefreshReport();
    },

    get_reportAreaContentType: function()
    {
        var internalViewer = this._getInternalViewer();
        return internalViewer.get_reportAreaContentType();
    },

    get_promptAreaCollapsed: function()
    {
        var internalViewer = this._getInternalViewer();
        return !internalViewer.ArePromptsVisible();
    },

    set_promptAreaCollapsed: function(value)
    {

        var internalViewer = this._getInternalViewer();

        var currentPromptAreaVisibility = this.get_promptAreaCollapsed();
        if (currentPromptAreaVisibility != value)
        {
            internalViewer.SetPromptAreaVisibility(!value);
            this.recalculateLayout();
        }
    },

    get_documentMapCollapsed: function()
    {
        var internalViewer = this._getInternalViewer();
        return !internalViewer.AreDocMapAreaVisible();
    },

    set_documentMapCollapsed: function(value)
    {
        var internalViewer = this._getInternalViewer();

        var currentDocMapAreaVisibility = this.get_documentMapCollapsed();
        if (currentDocMapAreaVisibility != value)
            internalViewer.SetDocMapAreaVisibility(!value);
    },

    get_zoomLevel: function()
    {
        var internalViewer = this._getInternalViewer();
        return internalViewer.get_zoomLevel();
    },

    set_zoomLevel: function(value)
    {
        var internalViewer = this._getInternalViewer();

        var currentZoomLevel = this.get_zoomLevel();
        if (currentZoomLevel != value)
        {
            internalViewer.set_zoomLevel(value);
            this.raisePropertyChanged("zoomLevel");
        }
    },

    get_reportAreaScrollPosition: function()
    {
        var internalViewer = this._getInternalViewer();
        return internalViewer.get_reportAreaScrollPosition();
    },

    set_reportAreaScrollPosition: function(scrollPoint)
    {
        if (scrollPoint == null)
            throw Error.argumentNull("scrollPoint");
        else if (!Sys.UI.Point.isInstanceOfType(scrollPoint))
            throw Error.argumentType("scrollPoint", null, Sys.UI.Point);

        var internalViewer = this._getInternalViewer();
        return internalViewer.set_reportAreaScrollPosition(scrollPoint);
    },

    get_isLoading: function()
    {
        var internalViewer = this._tryGetInternalViewer();

        if (internalViewer == null)
            return true;
        else
            return internalViewer.get_isLoading();
    },

    _get_direction: function()
    {
        // It is ok to access the internal viewer for the direction field while it is loading.
        var internalViewer = this._tryGetInternalViewer();
        if (internalViewer == null)
            throw Error.invalidOperation("Unexpected error: InternalViewer unavailable for _get_direction.");

        return internalViewer.GetDirection();
    },

    _get_toolBarUpdate : function()
    {
        var internalViewer = this._tryGetInternalViewer();
        if (internalViewer == null)
            throw Error.invalidOperation("Unexpected error: InternalViewer unavailable for _get_toolBarUpdate.");

        return internalViewer.GetToolBarUpdate();
    },

    _getInternalViewer: function()
    {
        var internalViewer = this._tryGetInternalViewer();

        if (internalViewer == null || this.get_isLoading())
            throw Error.invalidOperation("The report or page is being updated.  Please wait for the current action to complete.");

        return internalViewer;
    },

    _tryGetInternalViewer: function()
    {
        if (this._internalViewerId != null)
        {
            var internalViewerObject = $get(this._internalViewerId);
            if (internalViewerObject != null)
                return internalViewerObject.control;
        }
            
        return null;
    },

    _ensureReportAreaHasReportPage: function()
    {
        // This may throw if the viewer is still loading.  That's ok.  It's also
        // a requirement that the viewer not be loading when a method requires
        // that a report page be visible.
        var reportAreaContentType = this.get_reportAreaContentType();

        if (reportAreaContentType != Microsoft.Reporting.WebFormsClient.ReportAreaContent.ReportPage)
            this._throwExceptionForInvalidState();
    },

    _throwExceptionForInvalidState: function()
    {
        throw Error.invalidOperation("The operation cannot be performed because there is no report loaded.");
    },

    _onAppLoad: function()
    {
        // When a new internal viewer is created, hook up to events exposed by it
        if (this._needHookEvents)
        {
            var internalViewer = this._tryGetInternalViewer();
            if (internalViewer != null)
            {
                internalViewer.add_disposing(this._onInternalViewerDisposingDelegate);
                internalViewer.add_propertyChanged(this._onReportAreaContentChangedDelegate);
                internalViewer.add_reportAreaNewContentVisible(this._onReportAreaNewContentVisibleDelegate);
                internalViewer.add_propertyChanged(this._onInternalViewerLoadingDelegate);
                internalViewer.add_propertyChanged(this._onReportAreaScrollPositionChangedDelegate);
                internalViewer.add_propertyChanged(this._onDocMapAreaCollapseChangedDelegate);
                internalViewer.add_propertyChanged(this._onPromptAreaCollapseChangedDelegate);

                this._needHookEvents = false;
            }
        }
    },

    _onInternalViewerDisposing: function()
    {
        // When the internal viewer is disposed, mark that we need to hook up events to the
        // one that gets created after the postback.
        this._needHookEvents = true;
    },

    _onReportAreaContentChanged: function(sender, e)
    {
        if (e.get_propertyName() == "reportAreaContentType")
        {
            // Propagate the event to users of this class
            this.raisePropertyChanged("reportAreaContentType");
        }
    },

    _onReportAreaNewContentVisible: function(sender, e)
    {
        var reportAreaNewContentVisibleHandler = this.get_events().getHandler("reportAreaNewContentVisible");
        if (reportAreaNewContentVisibleHandler)
            reportAreaNewContentVisibleHandler(this, e);
    },

    _add_reportAreaNewContentVisible: function(handler)
    {
        this.get_events().addHandler("reportAreaNewContentVisible", handler);
    },

    _remove_reportAreaNewContentVisible: function(handler)
    {
        this.get_events().removeHandler("reportAreaNewContentVisible", handler);
    },

    _onInternalViewerLoading: function(sender, e)
    {
        if (e.get_propertyName() == "isLoading")
        {
            // Propagate the event to users of this class
            this.raisePropertyChanged("isLoading");
        }
    },

    _onReportAreaScrollPositionChanged: function(sender, e)
    {
        if (e.get_propertyName() == "reportAreaScrollPosition")
        {
            // Propagate the event to users of this class
            this.raisePropertyChanged("reportAreaScrollPosition");
        }
    },

    _onDocMapAreaCollapseChanged: function(sender, e)
    {
        if (e.get_propertyName() == "documentMapCollapsed")
        {
            // Propagate the event to users of this class
            this.raisePropertyChanged("documentMapCollapsed");
        }
    },
    
    _onPromptAreaCollapseChanged: function(sender, e)
    {
        if (e.get_propertyName() == "promptAreaCollapsed")
        {
            // Propagate the event to users of this class
            this.raisePropertyChanged("promptAreaCollapsed");
        }
    }
}

Microsoft.Reporting.WebFormsClient.ReportViewer.registerClass("Microsoft.Reporting.WebFormsClient.ReportViewer", Sys.Component);

Microsoft.Reporting.WebFormsClient.ReportAreaContent = function() { };
Microsoft.Reporting.WebFormsClient.ReportAreaContent.prototype =
{
    None: 0,
    ReportPage: 1,
    Error: 2
}
Microsoft.Reporting.WebFormsClient.ReportAreaContent.registerEnum("Microsoft.Reporting.WebFormsClient.ReportAreaContent");
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._DropDownMenu = function(element)
{
    Microsoft.Reporting.WebFormsClient._DropDownMenu.initializeBase(this, [element]);
    this.NormalStyles = null;
    this.HoverStyles = null;
    this.ButtonId = null;
    this.MenuId = null;
    this.ButtonImages = null;
    this.ArrowImages = null;
    this._Enabled = false;

    this._hideMenuDelegate = Function.createDelegate(this, this._hideMenu)
    this._keyDownDelegate = Function.createDelegate(this, this._onMenuKeyDown)

    this._button = null;
    this._buttonLink = null;
    this._menu = null;
    this._adorner = null;
    this._menuItemElements = null;
    this._selectedItem = null;
    this._ButtonImages = null;
    this._ArrowImages = null;
}

Microsoft.Reporting.WebFormsClient._DropDownMenu.prototype = {

    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._DropDownMenu.callBaseMethod(this, 'initialize');
        var element = this.get_element();
        this._button = $get(this.ButtonId);
        this._menu = $get(this.MenuId);
        $addHandlers(this._button,
            { "mouseover": this._onButtonMouseOver,
                "mouseout": this._onButtonMouseOut,
                "click": this._onButtonClick
            },
            this);
        // initialize button style
        _$RVCommon.setButtonStyle(this._button.parentNode, this._normalStyles, "default");


        // The only hyperlink in the button can accept and handles the keyboard.
        this._buttonLink = $get(this.ButtonId + "Link");
        $addHandlers(this._buttonLink, { "click": this._onButtonClick, keydown: this._onButtonKeyDown }, this);

        this._adorner = document.createElement("div");
        this._adorner.style.position = "absolute";
        this._adorner.style.zIndex = -1;
        this._adorner.style.top = "0px"
        this._adorner.style.left = "0px";
        this._adorner.style.width = "26px";
        this._adorner.style.opacity = "0.05";
        this._adorner.style.filter = 'alpha(opacity=5)';

        this._adorner.style.backgroundColor = "black";
        this._menu.appendChild(this._adorner);

        // initialize menu style
        var elements = this._menu.getElementsByTagName("a");
        this._menuItemElements = new Array();
        this._selectedItem = null;
        if (elements.length > 0)
        {
            var isRtl = this._isRTL();
            for (var index = 0; index < elements.length; index++)
            {
                $addHandlers(elements[index],
                { "mouseover": this._onMenuItemMouseOver,
                    "focus": this._onMenuItemMouseOver,
                    "click": this._onMenuItemClick
                },
                this);
                if (!isRtl)
                {
                    elements[index].style.paddingLeft = "32px";
                }
                else
                {
                    elements[index].style.paddingRight = "32px";
                }
                this._menuItemElements[this._menuItemElements.length] = elements[index];
            }
        }
        Sys.UI.DomElement.setVisible(this._menu, false)
        this._ButtonImages = this._loadImages(this.ButtonImages);
        this._ArrowImages = this._loadImages(this.ArrowImages);
    },

    dispose: function()
    {
        $clearHandlers(this._button);
        $clearHandlers(this._buttonLink);
        $clearHandlers(this._menu);
        for (var index = 0; index < this._menuItemElements.length; index++)
        {
            $clearHandlers(this._menuItemElements[index]);
        }
        delete this._hideMenuDelegate;
        delete this._keyDownDelegate;

        this._button = null;
        this._buttonLink = null;
        this._menu = null;
        this._adorner = null;
        this._menuItemElements = null;
        this._selectedItem = null;
        this._ButtonImages = null;
        this._ArrowImages = null;

        Microsoft.Reporting.WebFormsClient._DropDownMenu.callBaseMethod(this, 'dispose');
    },

    set_NormalStyles: function(value) { this._normalStyles = value; },
    get_NormalStyles: function() { return this._normalStyles; },

    set_HoverStyles: function(value) { this._hoverStyles = value; },
    get_HoverStyles: function() { return this._hoverStyles; },

    _loadImages: function(imagesInfo)
    {
        var images = Sys.Serialization.JavaScriptSerializer.deserialize(imagesInfo)
        images._Enabled = document.createElement("img")
        images._Enabled.src = images.EnabledUrl;
        images._Disabled = document.createElement("img")
        images._Disabled.src = images.DisabledUrl;
        return images;
    },

    get_Enabled: function()
    {
        return this._Enabled;
    },

    set_Enabled: function(value)
    {
        if (this._ButtonImages)
        {
            if (value)
            {
                $get(this.ButtonId + "Img").src = this._ButtonImages.EnabledUrl;
                $get(this.ButtonId + "ImgDown").src = this._ArrowImages.EnabledUrl;
            }
            else
            {
                $get(this.ButtonId + "Img").src = this._ButtonImages.DisabledUrl;
                $get(this.ButtonId + "ImgDown").src = this._ArrowImages.DisabledUrl;
            }
            // property disabled of type boolean is defined in W3C DOM Level 1
            this._buttonLink.disabled = !(value == true);
            this._buttonLink.style.cursor = this._buttonLink.disabled ? "default" : "pointer";
            this._hideMenu(null);
            this._Enabled = value;
            this.raisePropertyChanged('Enabled');
        }
        else
        {
            this._Enabled = value;
        }
    },

    SetActive: function(value)
    {
        this.set_Enabled(value);
    },
    /// Open menu button handlers
    _onButtonMouseOver: function(e)
    {
        if (this._Enabled)
        {
            _$RVCommon.setButtonStyle(this._button.parentNode, this._hoverStyles, "pointer");
            e.preventDefault();
        }
    },

    _onButtonMouseOut: function(e)
    {
        if (Sys.UI.DomElement.getVisible(this._menu)) return;
        _$RVCommon.setButtonStyle(this._button.parentNode, this._normalStyles, "default");
        e.preventDefault();
    },

    _onButtonClick: function(e)
    {
        if (this._Enabled)
            this._showMenu(true);

        e.preventDefault();
    },
    _onButtonKeyDown: function(e)
    {
        if (e.keyCode == Sys.UI.Key.space)
        {
            this._onButtonClick(e);
            e.preventDefault();
        }
    },

    // Menu utility and events
    _isMenuVisible: function()
    {
        return this._menu && Sys.UI.DomElement.getVisible(this._menu)
    },

    _showMenu: function()
    {
        if (!this._isMenuVisible())
        {
            Sys.UI.DomElement.setVisible(this._menu, true);
            this._adorner.style.height = this._menu.clientHeight + "px";
            if (this._isRTL())
            {
                this._adorner.style.left = (this._menu.clientWidth - 24) + "px"
            }

            this._ensureIsOnScreen(this._menu, this._button);

            this._selectMenuItem(this._menuItemElements[0])
            $addHandler(document, "mousedown", this._hideMenuDelegate);
            $addHandler(document, "keydown", this._keyDownDelegate);
        }
    },

    _ensureIsOnScreen: function(element, anchor)
    {
        // make sure any previous value gets cleared, as
        // it's possible to exit this method not wanting to make any adjustments
        element.style.left = "";
        element.style.right = "";

        var elementDims = _$RVCommon.getBounds(element);
        var anchorDims = _$RVCommon.getBounds(anchor);

        // how far over from the left edge of the physical window is the anchor
        // in both RTL and LTR mode, this method always measures from left side of window to left edge of element    
        var anchorWindowOffsetLeft = anchor.getBoundingClientRect().left;

        if (this._isRTL())
        {
            // if the space between the left edge of the window and the anchor
            // is less than the size of the element
            if (anchorWindowOffsetLeft < elementDims.width)
            {
                // then nudge it to the right
                // style.left is ignored in RTL mode
                element.style.right = (anchorWindowOffsetLeft - elementDims.width + anchorDims.width) + "px";
            }
        }
        else // in LTR mode
        {
            var winDims = _$RVCommon.windowRect();
            var outerEdge = anchorWindowOffsetLeft + elementDims.width;

            // if the right side of this element is beyond the right side of the window
            if (outerEdge > winDims.clientWidth)
            {
                // nudge it back to the left to fix it
                element.style.left = (winDims.clientWidth - outerEdge) + "px";
            }
        }
    },

    _hideMenu: function(e)
    {
        if (this._isMenuVisible() && (e == null || e.target != this._selectedItem))
        {
            Sys.UI.DomElement.setVisible(this._menu, false);
            $removeHandler(document, "mousedown", this._hideMenuDelegate);
            $removeHandler(document, "keydown", this._keyDownDelegate);
            // takes the button in normal visual state
            _$RVCommon.setButtonStyle(this._button.parentNode, this._normalStyles, "default");
        }
    },

    _onMenuKeyDown: function(e)
    {
        var index = Array.indexOf(this._menuItemElements, this._selectedItem)
        if (index != -1)
        {
            if (e.keyCode == Sys.UI.Key.down || e.keyCode == Sys.UI.Key.left)
            {
                index = (index < this._menuItemElements.length - 1) ? index + 1 : 0;
                this._selectMenuItem(this._menuItemElements[index])
            }
            else if (e.keyCode == Sys.UI.Key.up || e.keyCode == Sys.UI.Key.right)
            {
                index = (index > 0) ? index - 1 : this._menuItemElements.length - 1;
                this._selectMenuItem(this._menuItemElements[index])
            }
            else if (e.keyCode == Sys.UI.Key.esc || e.keyCode == Sys.UI.Key.tab)
            {
                this._hideMenu();
            }
            else if (e.keyCode == Sys.UI.Key.enter)
            {
                this._menuItemElements[index].click();
            }
        }
        e.preventDefault();
    },

    // Menu item utility and avents
    _onMenuItemClick: function()
    {
        this._hideMenu(null);
    },

    _onMenuItemMouseOver: function(e)
    {
        if (e.target && e.target.tagName && e.target.tagName.toUpperCase() == "A")
        {
            this._selectMenuItem(e.target);
        }
        e.preventDefault();
    },

    _selectMenuItem: function(element)
    {
        if (element)
        {
            // This element will be selected so force focus to allow the screen reader to read it.
            // Even if this element was already selected, as in the case of opening the drop down
            // menu multiple times, trigger the screen reader to read it again.
            element.focus();
        }

        if (this._selectedItem == element)
        {
            return;
        }
        this._selectedItem = null;
        if (element)
        {
            _$RVCommon.setButtonStyle(element.parentNode, this._hoverStyles, "pointer");
            element._selected = true;
            if (element.style.display !== "none") {
                try { element.focus(); } catch (exception) { } 
            }            
            this._selectedItem = element;
        }
        // unselect all other menu items.
        for (var index = 0; index < this._menuItemElements.length; index++)
        {
            if (this._menuItemElements[index] != element &&
                 (this._menuItemElements[index]._selected || typeof (this._menuItemElements[index]._selected) == "undefined")
                )
            {
                _$RVCommon.setButtonStyle(this._menuItemElements[index].parentNode, this._normalStyles, "default");
                this._menuItemElements[index]._selected = false;
            }
        }
    },

    _isRTL: function()
    {
        var element = this.get_element();
        if (Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection)
        {
            return Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection(element) == 'rtl';
        }
        return false;
    }
}

Microsoft.Reporting.WebFormsClient._DropDownMenu.registerClass('Microsoft.Reporting.WebFormsClient._DropDownMenu', Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._Splitter = function(element)
{
    Microsoft.Reporting.WebFormsClient._Splitter.initializeBase(this, [element]);
    this.Vertical = true;
    this.Resizable = true;
    this.NormalStyle = null;
    this.HoverStyle = null;
    this.NormalColor = null;
    this.HoverColor = null;
    this.StorePositionField = null;
    this.StoreCollapseField = null;
    this.ImageId = null;
    this.ImageCollapse = null;
    this.ImageCollapseHover = null;
    this.ImageExpand = null;
    this.ImageExpandHover = null;
    this.Enabled = true;

    this._updating = false;
    this._image = null;
    this._StorePositionField = null;
    this._StoreCollapseField = null;
    this._onMouseMoveDelegate = null;
    this._onMouseUpDelegate = null;
    this._onSelectStartDelegate = null;
    this.IsCollapsable = true;
}

Microsoft.Reporting.WebFormsClient._Splitter.prototype = {

    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._Splitter.callBaseMethod(this, 'initialize');

        this._image = $get(this.ImageId);
        this._StorePositionField = $get(this.StorePositionField);
        this._StoreCollapseField = $get(this.StoreCollapseField);

        this._onMouseMoveDelegate = Function.createDelegate(this, this._onMouseMove);
        this._onMouseUpDelegate = Function.createDelegate(this, this._onMouseUp);
        this._onSelectStartDelegate = Function.createDelegate(this, this._onSelectStart);

        $addHandlers(this.get_element().parentNode, {
            "mouseover": this._onMouseOver,
            "focus": this._onMouseOver,
            "mouseout": this._onMouseOut,
            "mousedown": this._onMouseDown,
            "click": this._onClick
        },
                this
        );

        $addHandlers(this._image, {
            "click": this._onImageClick,
            "mouseover": this._onImageMouseOver,
            "focus": this._onImageMouseOver,
            "mouseout": this._onImageMouseOut
        },
            this
        );
    },

    dispose: function()
    {
        $clearHandlers(this.get_element().parentNode);
        $clearHandlers(this._image);

        delete this._onMouseMoveDelegate;
        delete this._onMouseUpDelegate;
        delete this._onSelectStartDelegate;

        this._image = null;
        this._StorePositionField = null;
        this._StoreCollapseField = null;

        Microsoft.Reporting.WebFormsClient._Splitter.callBaseMethod(this, 'dispose');
    },


    SetActive: function(active)
    {
        this.Enabled = active;
    },

    _setStyle: function(className, color, cursor)
    {
        var element = this.get_element();
        var elementForStyles = element.parentNode;

        elementForStyles.style.cursor = cursor;
        if (className)
        {
            elementForStyles.className = className;
        }
        else
        {
            elementForStyles.style.backgroundColor = color;
        }
    },

    _setImage: function(hovering)
    {
        var collapsed = this._getCollapsed();
        var imgsrc = null;
        if (hovering)
        {
            imgsrc = collapsed ? this.ImageExpandHover : this.ImageCollapseHover;
        }
        else
        {
            imgsrc = collapsed ? this.ImageExpand : this.ImageCollapse;
        }

        this._image.src = imgsrc;
    },

    _onImageClick: function(e)
    {
        if (this.Enabled)
            this.raiseCollapsing(!this._getCollapsed());
        e.preventDefault();
        e.stopPropagation(); // Don't let image and splitter both handle the event
    },

    _onClick: function(e)
    {
        if ((!this.Resizable || this._getCollapsed()) && this.Enabled)
            this.raiseCollapsing(!this._getCollapsed());
        e.preventDefault();
        e.stopPropagation(); // Don't let image and splitter both handle the event
    },

    _setCollapsed: function(value)
    {
        this._StoreCollapseField.value = value ? "true" : "false";
        this._setImage(false);
    },

    _getCollapsed: function()
    {
        return this._StoreCollapseField.value == "true";
    },

    _getCollapsable: function()
    {
        return this.IsCollapsable;
    },

    _setSize: function(value)
    {
        this._StorePositionField.value = value.toString();
    },

    _getSize: function()
    {
        return parseInt(this._StorePositionField.value);
    },

    _onSelectStart: function(e)
    {
        e.preventDefault();
        return false;
    },

    _onMouseOut: function(e)
    {
        this._setStyle(this.NormalStyle, this.NormalColor, "default");
        this._setImage(false);
        e.preventDefault();
        return false;
    },

    _onMouseOver: function(e)
    {
        if (this.Enabled)
        {
            if (!this.Resizable || this._getCollapsed())
            {
                this._setStyle(this.HoverStyle, this.HoverColor, "pointer");
                this._setImage(true);
            }
            else
            {
                var cursor = this.Vertical ? "w-resize" : "n-resize";
                this._setStyle(this.NormalStyle, this.NormalColor, cursor);
            }
        }
        e.preventDefault();
        e.stopPropagation();
        return false;
    },

    _onMouseDown: function(e)
    {
        if (this.Resizable)
        {
            this._lastPosition = { X: e.clientX, Y: e.clientY };
            var t = this._getMouseObjects();
            $addHandler(t.target, 'mousemove', this._onMouseMoveDelegate);
            $addHandler(t.target, 'mouseup', this._onMouseUpDelegate);
            $addHandler(t.target, 'selectstart', this._onSelectStartDelegate);
            if (t.isIE)
                t.target.setCapture();
        }
    },

    _onMouseUp: function(e)
    {
        if (this.Resizable)
        {
            var t = this._getMouseObjects();
            $removeHandler(t.target, 'mousemove', this._onMouseMoveDelegate);
            $removeHandler(t.target, 'mouseup', this._onMouseUpDelegate);
            $removeHandler(t.target, 'selectstart', this._onSelectStartDelegate);
            if (t.isIE)
                t.target.releaseCapture();
        }
    },

    _onImageMouseOver: function(e)
    {
        if (this.Enabled)
        {
            this._setStyle(this.HoverStyle, this.HoverColor, "pointer");
            this._setImage(true);
        }

        e.preventDefault();
        e.stopPropagation();
        return false;
    },

    _onImageMouseOut: function(e)
    {
        this._setStyle(this.NormalStyle, this.NormalColor, "default");
        this._setImage(false);

        e.preventDefault();
        return false;
    },

    _getMouseObjects: function()
    {
        if (!this._mouseTrackingObject)
        {
            this._mouseTrackingObject =
            {
                isIE: Sys.Browser.agent == Sys.Browser.InternetExplorer,
                target: Sys.Browser.agent == Sys.Browser.InternetExplorer ? document.body : _$RVCommon.getWindow()
            }
        }
        return this._mouseTrackingObject;
    },

    _onMouseMove: function(e)
    {
        var newPosition = { X: e.clientX, Y: e.clientY };
        if (this.Resizable && !this._getCollapsed() && this.Enabled)
        {
            var delta = 0;
            if (this.Vertical)
                delta = (newPosition.X - this._lastPosition.X) * (this._isRTL() ? -1 : 1);
            else
                delta = (newPosition.Y - this._lastPosition.Y);

            this.raiseResizing(delta);

            this._lastPosition = newPosition;
        }
    },
    _isRTL: function()
    {
        var element = this.get_element();
        if (Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection)
        {
            return Microsoft.Reporting.WebFormsClient._InternalReportViewer.GetRTLDirection(element) == 'rtl';
        }
        return false;
    },
    add_resizing: function(handler)
    {
        this.get_events().addHandler('resizing', handler);
    },
    remove_resizing: function(handler)
    {
        this.get_events().removeHandler('resizing', handler);
    },
    raiseResizing: function(delta)
    {
        var onResizingHandler = this.get_events().getHandler('resizing');
        if (onResizingHandler)
        {
            var args = new Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs();
            args.set_delta(delta);
            onResizingHandler(this, args);
            if (args.get_size() != 0)
            {
                this._setSize(args.get_size());
            }
        }
    },
    add_collapsing: function(handler)
    {
        this.get_events().addHandler('collapsing', handler);
    },
    remove_collapsing: function(handler)
    {
        this.get_events().removeHandler('collapsing', handler);
    },
    raiseCollapsing: function(collapse)
    {
        var onCollapsingHandler = this.get_events().getHandler('collapsing');
        if (onCollapsingHandler)
        {
            var args = new Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs();
            args.set_collapse(collapse);
            onCollapsingHandler(this, args);
            this._setCollapsed(args.get_collapse());
        }
    }
}

Microsoft.Reporting.WebFormsClient._Splitter.registerClass('Microsoft.Reporting.WebFormsClient._Splitter', Sys.UI.Control);


Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs = function () {
    Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs.initializeBase(this);
    this._delta = 0;
    this._size  = 0;
}

Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs.prototype = {
    get_delta: function()
    {
        return this._delta;
    },
    set_delta: function(value)
    {
        this._delta = value;
    },
    get_size: function()
    {
        return this._size;
    },
    set_size: function(value)
    {
        this._size = value;
    }
}
Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs.registerClass('Microsoft.Reporting.WebFormsClient._SplitterResizeEventArgs', Sys.EventArgs);

Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs = function () {
    Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs.initializeBase(this);
    this._collapse = false;
}

Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs.prototype = {
    get_collapse: function()
    {
        return this._collapse;
    },
    set_collapse: function(value)
    {
        this._collapse = value;
    }
}

Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs.registerClass('Microsoft.Reporting.WebFormsClient._SplitterCollapseEventArgs', Sys.EventArgs);// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace('Microsoft.Reporting.WebFormsClient');

Microsoft.Reporting.WebFormsClient.ResizableControlBehavior = function(element)
{
    Microsoft.Reporting.WebFormsClient.ResizableControlBehavior.initializeBase(this, [element]);

    this.MinimumWidth = 0;
    this.MinimumHeight = 0;
    this.MaximumWidth = 100000;
    this.MaximumHeight = 100000;
    this.GripImage = null;
    this.GripImageRTL = null;
    this.Overflow = "auto";
    // Variables
    this._ctrl = null;
    this._frame = null;
    this._handle = null;
    this._tracking = false;
    this._lastClientX = 0;
    this._lastClientY = 0;
    this._leftOffset = 0;
    // Delegates
    this._onmousedownDelegate = null;
    this._onmousemoveDelegate = null;
    this._onmouseupDelegate = null;
    this._onselectstartDelegate = null;
    this._invalidateDelegate = null;
    this._tracking = false;
}

Microsoft.Reporting.WebFormsClient.ResizableControlBehavior.prototype = {
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient.ResizableControlBehavior.callBaseMethod(this, 'initialize');

        this._ctrl = this.get_element();

        this._ctrlLeft = parseInt(this._ctrl.style.left);

        // the frame will contain the control children and will be resizable
        this._frameContainer = document.createElement("span");
        this._frameContainer.style.cssText = "margin: 0px; pading: 0px; background-color: window;";
        this._frame = document.createElement('DIV');
        this._frame.style.overflow = this.Overflow;
        this._ctrl.style.overflow = 'visible';
        this._moveChildren(this._ctrl, this._frame)
        this._frameContainer.appendChild(this._frame);
        this._ctrl.appendChild(this._frameContainer);
        this._frame.style.width = this.MinimumWidth + "px";
        this._frame.style.height = this.MinimumHeight + "px";

        this._gripImageHolder = document.createElement('DIV');
        this._gripImageHolder.style.cssText = "height:16px; width: 100%; pading: 0px; margin: 0px; border-top: solid 1px lightgray; background-color: window;";
        this._frameContainer.appendChild(this._gripImageHolder);

        this._gripImage = document.createElement('IMG');
        this._gripImage.style.display = "none"
        this._gripImageHolder.appendChild(this._gripImage);

        this._onmousedownDelegate = Function.createDelegate(this, this._onmousedown);
        $addHandler(this._gripImage, 'mousedown', this._onmousedownDelegate);
        this._onmousemoveDelegate = Function.createDelegate(this, this._onmousemove);
        this._onmouseupDelegate = Function.createDelegate(this, this._onmouseup);
        this._onselectstartDelegate = Function.createDelegate(this, this._onselectstart);

        // In some browsers (ex.IE quirks mode) this._frame, as brand new item in the DOM, doesn't have offsetXXX calculated yet.
        // OffsetXXX is used in resizing function. We have to call resizeControl out of the thread once to set initial minimum size.
        this._invalidateDelegate = Function.createDelegate(this, this._reset);
        window.setTimeout(this._invalidateDelegate, 0);

    },

    _reset: function()
    {

        var windowRect = _$RVCommon.windowRect()
        var isRtl = this._isRTL(this._ctrl);
        var left = this._ctrlLeft;

        // flip the grip on if the space is less than  this.MinimumWidth
        if ((Sys.Browser.agent == Sys.Browser.InternetExplorer) && this._isRTL(_$RVCommon.getDocument()))
        {
            // IE flips the coord system.
            left = this._ctrlLeft + (windowRect.scrollWidth - windowRect.left - windowRect.width)
        }

        var noSpaceLeft = ((left - this.MinimumWidth) < windowRect.left);
        var noSpaceRight = ((left + this.MinimumWidth * 2) > windowRect.right);

        // if there is no space on both sides or there is enough space on both sides - keep the rtl settings.
        if ((noSpaceLeft && noSpaceRight) || (!noSpaceLeft && !noSpaceRight))
            this._gripImageHolder.style.direction = isRtl ? "rtl" : "ltr";
        else if (isRtl && noSpaceLeft)
            this._gripImageHolder.style.direction = "ltr";
        else if (!isRtl && noSpaceRight)
            this._gripImageHolder.style.direction = "rtl";
        else
            this._gripImageHolder.style.direction = isRtl ? "rtl" : "ltr";

        this._setRtlCues();
        this.set_Size({ width: this.MinimumWidth, height: this.MinimumHeight });

        if (this._frame.childNodes[0].focus)
            this._frame.childNodes[0].focus();
        
    },

    _setRtlCues: function()
    {
        var rtl = this._isRTL();
        // for IE
        this._gripImage.style.styleFloat = (rtl ? "left" : "right");
        // for other browsers
        this._gripImage.style.cssFloat = (rtl ? "left" : "right");
        if (_$RVCommon.isIEQuirksMode())
        {
            // IE in quirks mode due float position shifts the image with 3px.
            if (rtl)
                this._gripImage.style.marginLeft = "-3px";
            else
                this._gripImage.style.marginRight = "-3px";
        }
        this._gripImage.style.cursor = (rtl ? "ne-resize" : "se-resize")
        this._gripImage.src = (rtl ? this.GripImageRTL : this.GripImage);
        if (this._gripImage.style.display == "none")
        {
            this._gripImage.style.display = "";
        }
    },

    dispose: function()
    {
        if (this._onmousedownDelegate)
        {
            $removeHandler(this._gripImage, 'mousedown', this._onmousedownDelegate);
            delete this._onmousedownDelegate;
            this._onmousedownDelegate = null;
        }

        if (this._tracking)
        {
            this._onmouseup();
            delete this._onmousemoveDelegate;
            this._onmousemoveDelegate = null;
            delete this._onmouseupDelegate;
            this._onmouseupDelegate = null;
            delete this._onselectstartDelegate;
            this._onselectstartDelegate = null;
        }

        if (this._frame)
        {
            this._ctrl.removeChild(this._frameContainer);
            this._moveChildren(this._frame, this._ctrl)
            this._frame = null;
        }

        if (this._invalidateDelegate)
        {
            delete this._invalidateDelegate;
            this._invalidateDelegate = null;
        }

        Microsoft.Reporting.WebFormsClient.ResizableControlBehavior.callBaseMethod(this, 'dispose');
    },

    _moveChildren: function(fromElement, toElement)
    {
        while (fromElement.childNodes.length > 0)
        {
            var child = fromElement.childNodes[0];
            fromElement.removeChild(child);
            toElement.appendChild(child)
        }
    },

    _onmousedown: function(e)
    {
        this._tracking = true;
        this._lastClientX = e.clientX;
        this._lastClientY = e.clientY;
        var t = this._getMouseObjects();
        $addHandler(t.target, 'mousemove', this._onmousemoveDelegate);
        $addHandler(t.target, 'mouseup', this._onmouseupDelegate);
        $addHandler(t.target, 'selectstart', this._onselectstartDelegate);
        if (t.isIE)
            t.target.setCapture();

        e.preventDefault();
        return false;
    },

    _onmousemove: function(e)
    {
        if (this._tracking)
        {
            var deltaX = (e.clientX - this._lastClientX);
            var deltaY = (e.clientY - this._lastClientY);
            this._resizeControl(deltaX, deltaY);
            this._lastClientX = e.clientX;
            this._lastClientY = e.clientY;
        }
        e.preventDefault();
        return false;
    },

    _onmouseup: function(e)
    {
        this._tracking = false;
        this._shadowSize = null;
        var t = this._getMouseObjects();
        $removeHandler(t.target, 'mousemove', this._onmousemoveDelegate);
        $removeHandler(t.target, 'mouseup', this._onmouseupDelegate);
        $removeHandler(t.target, 'selectstart', this._onselectstartDelegate);
        if (t.isIE)
            t.target.releaseCapture();
        if (e) e.preventDefault();
        return false;
    },
    _getMouseObjects: function()
    {
        if (!this._mouseTrackingObject)
        {
            var element = this._ctrl;
            this._mouseTrackingObject =
            {
                isIE: Sys.Browser.agent == Sys.Browser.InternetExplorer,
                target: Sys.Browser.agent == Sys.Browser.InternetExplorer ? element : _$RVCommon.getWindow()
            }
        }
        return this._mouseTrackingObject;
    },
    _onselectstart: function(e)
    {
        e.preventDefault();
        return false;
    },

    _resizeControl: function(deltaX, deltaY)
    {
        if (this._frame)
        {
            if (this._isRTL())
            {
                deltaX = deltaX * -1;
            }

            if (!this._shadowSize)
            {
                this._shadowSize = this.get_Size();
            }

            // Calculate new frame width/height
            var currentSize = this._shadowSize;

            var newWidth = Math.min(Math.max(currentSize.width + deltaX, Math.max(this.MinimumWidth, 16)), this.MaximumWidth);
            var newHeight = Math.min(Math.max(currentSize.height + deltaY, Math.max(this.MinimumHeight, 16)), this.MaximumHeight);
            this._shadowSize = { width: newWidth, height: newHeight };

            var windowRect = _$RVCommon.windowRect()
            var adornerHeight = this._gripImageHolder.offsetHeight;
            // limitMaxTolerance is the number in pixels which decreases the calculated width and height, 
            // otherwise the scrollbars will appear before reaching the limit. 
            var limitMaxTolerance = Sys.Browser.agent == Sys.Browser.InternetExplorer ? 2 : 1;
            var limitWidth = windowRect.right - this._ctrl.offsetLeft - limitMaxTolerance;
            var limitHeight = windowRect.bottom - this._ctrl.offsetTop - limitMaxTolerance - adornerHeight;

            // Since this._ctrlLeft is not explicitly set in all scenarios, we must check for NaN and default to 0
            var ctrlLeftPos = isNaN(this._ctrlLeft) ? 0 : this._ctrlLeft;
            if (this._isRTL())
            {
                if (Sys.Browser.agent == Sys.Browser.InternetExplorer && this._isRTL(_$RVCommon.getDocument()))
                {
                    // IE reverse the coordinate system in RTL;
                    limitWidth = ctrlLeftPos + this.MinimumWidth + (windowRect.scrollWidth - windowRect.left - windowRect.width);
                }
                else
                {
                    limitWidth = ctrlLeftPos + this.MinimumWidth - windowRect.left;
                }
            }

            var newWidth = Math.min(newWidth, limitWidth);
            var newHeight = Math.min(newHeight, limitHeight);

            this._frame.style.width = newWidth + 'px';
            this._frame.style.height = newHeight + 'px';

            // for IE quirs mode the size of the control have to be set explicitly
            // and border have to be taken in account because IE box model.
            if (_$RVCommon.isIEQuirksMode())
            {
                var border = (parseInt(this._ctrl.style.borderWidth) || 0) * 2;
                this._ctrl.style.width = (newWidth + border) + 'px';
                this._ctrl.style.height = (newHeight + adornerHeight + border) + 'px';
            }
            else
            {
                if (Sys.Browser.agent == Sys.Browser.InternetExplorer)
                {
                    // For IE strict mode we have to set all sizes explicitly.
                    this._frameContainer.style.width = newWidth + "px";
                    this._frameContainer.style.height = newHeight + "px";
                    this._ctrl.style.width = newWidth + "px";
                    this._ctrl.style.height = (newHeight + adornerHeight) + "px";
                }
                else
                {
                    // The this._ctrl, as outer container, should be resized automatically 
                    // to its content (this._frame) if width and height is not set.
                    this._frameContainer.style.width = "";
                    this._frameContainer.style.height = "";
                    this._ctrl.style.width = "";
                    this._ctrl.style.height = "";
                }

            }
            if (this._isRTL())
            {
                this._leftOffset = -(newWidth - this.MinimumWidth);
                this._ctrl.style.left = (ctrlLeftPos + this._leftOffset) + 'px'
            }
            this.raiseResizing();
        }
    },
    add_resizing: function(handler)
    {
        this.get_events().addHandler('resizing', handler);
    },
    remove_resizing: function(handler)
    {
        this.get_events().removeHandler('resizing', handler);
    },
    raiseResizing: function()
    {
        var onResizingHandler = this.get_events().getHandler('resizing');
        if (onResizingHandler)
        {
            onResizingHandler(this, Sys.EventArgs.Empty);
        }
    },
    get_Size: function()
    {
        if (this._frame)
        {
            return { width: parseInt(this._frame.style.width), height: parseInt(this._frame.style.height), fullHeight: parseInt(this._frame.style.height) + this._gripImageHolder.offsetHeight }
        }
        return { width: 0, height: 0 };
    },

    set_Size: function(value)
    {
        var size = this.get_Size();
        var deltaX = value.width - size.width;
        var deltaY = value.height - size.height;
        if (this._isRTL())
        {
            deltaX = deltaX * -1;
        }
        this._resizeControl(deltaX, deltaY);
        this.raisePropertyChanged('Size');
    },
    _isRTL: function(control)
    {
        if (!control)
        {
            control = this._gripImageHolder;
        }
        return _$RVCommon.getComputedStyle(control,"direction") != "ltr";
    }
}


Microsoft.Reporting.WebFormsClient.ResizableControlBehavior.registerClass('Microsoft.Reporting.WebFormsClient.ResizableControlBehavior', Sys.UI.Behavior);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._AsyncWaitControl = function(element)
{
    Microsoft.Reporting.WebFormsClient._AsyncWaitControl.initializeBase(this, [element]);

    this.ReportViewerId = null;
    this.WaitControlId = null;
    this.FixedTableId = null;
    this.ClientCanceledId = null;
    this.DisplayDelay = 0;
    this.SkipTimer = false;
    this._postBackElement = null;
    this.m_triggerIds = null;

    this.m_delayTimerCompletedDelegate = Function.createDelegate(this, this._onDelayStartTimerCompleted);
    this.m_onReportViewerLoadingChangedDelegate = Function.createDelegate(this, this._onReportViewerLoadingChanged);
    this.m_onPageRequestBeginRequestDelegate = Function.createDelegate(this, this._onPageRequestBeginRequest);
    this.m_onPageRequestEndRequestDelegate = Function.createDelegate(this, this._onPageRequestEndRequest);

    this.m_visiblePollingTimer = null;

    this.m_delayTimer = null;

    this.m_waitControl = null;

    this.m_reportViewer;

    this.m_reallyCanceled = false;
    this.m_waitVisible = false;
    this.m_transVisible = false;
}

Microsoft.Reporting.WebFormsClient._AsyncWaitControl.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._AsyncWaitControl.callBaseMethod(this, "initialize");
        if (this.ReportViewerId)
        {
            this.m_reportViewer = $find(this.ReportViewerId);

            if (this.m_reportViewer != null)
            {
                this.m_reportViewer.add_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
            }

            var pageRequestManager = this._getPageRequestManager();
            if (pageRequestManager)
            {
                pageRequestManager.add_beginRequest(this.m_onPageRequestBeginRequestDelegate);
                pageRequestManager.add_endRequest(this.m_onPageRequestEndRequestDelegate);
            }

            this.m_waitControl = $get(this.WaitControlId);
        }
    },

    get_TriggerIds: function()
    {
        return this.m_triggerIds;
    },

    set_TriggerIds: function(triggerIds)
    {
        this.m_triggerIds = triggerIds;
    },

    dispose: function()
    {
        if (this.m_onReportViewerLoadingChangedDelegate)
        {
            this.m_reportViewer.remove_propertyChanged(this.m_onReportViewerLoadingChangedDelegate);
            this.m_onReportViewerLoadingChangedDelegate = null;
            delete this.m_onReportViewerLoadingChangedDelegate;
        }

        var pageRequestManager = this._getPageRequestManager();
        if (pageRequestManager)
        {
            pageRequestManager.remove_beginRequest(this.m_onPageRequestBeginRequestDelegate);
            pageRequestManager.remove_endRequest(this.m_onPageRequestEndRequestDelegate);
        }

        if (this.m_onPageRequestBeginRequestDelegate)
        {
            this.m_onPageRequestBeginRequestDelegate = null;
            delete this.m_onPageRequestBeginRequestDelegate;
        }

        this._clearPollingTimer();
        this._clearDelayTimer();

        delete this.m_delayTimerCompletedDelegate;

        Microsoft.Reporting.WebFormsClient._AsyncWaitControl.callBaseMethod(this, "dispose");
    },

    _getPageRequestManager: function()
    {
        if (Sys.WebForms && Sys.WebForms.PageRequestManager)
            return Sys.WebForms.PageRequestManager.getInstance();

        return null;
    },

    _cancelCurrentPostback: function()
    {
        // there is a tricky race condition in this code. If pageRequestManager says we are in
        // a postback, it's possible for the postback to complete before we call abortPostBack().
        // That postback will "slip through the cracks", and we won't successfully cancel it.
        // m_reallycanceled lets us know we really want the current happenings to be canceled.
        // We listen to pageRequestManager's endRequest event. If m_reallyCanceled is true,
        // but the postback wasn't aborted, then it slipped through and we force the cancellation
        // in _onPageRequestEndRequest

        this.m_reallyCanceled = true;

        var pageRequestManager = this._getPageRequestManager();
        if (pageRequestManager && pageRequestManager.get_isInAsyncPostBack())
        {
            // if we are still in a postback, then great, all we have to do is kill it.
            // The viewer will be non the wiser, and we get a nice clean cancellation.
            pageRequestManager.abortPostBack();

            if (this._triggeringControlWasForThisViewer() && this._triggeringControlWasAsyncLoadTarget())
            {
                // we do need to let the server know a cancel happened, so we'll send that up in this hidden field
                var cancelField = $get(this.ClientCanceledId);
                cancelField.value = "true";
            }
        }
        else
        {
            // Not in an async postback? then the postback has finished and the report is loading
            // its images. In this case, the viewer is busy getting the report ready, so we have to actively stop this.
            this._cancelReportViewerLoading();
        }
    },

    _cancelReportViewerLoading: function()
    {
        var internalViewer = this.m_reportViewer._tryGetInternalViewer();

        if (internalViewer == null)
            throw Error.invalidOperation("Unexpected error: InternalViewer unavailable for calling OnUserCanceled.");

        internalViewer.OnUserCanceled();
    },

    _onPageRequestBeginRequest: function(sender, e)
    {
        this._postBackElement = e.get_postBackElement();
        this.m_reallyCanceled = false;
    },

    _onPageRequestEndRequest: function(sender, e)
    {
        // if user really did cancel, but this postback is claiming
        // it was never aborted, then our race condition occured, and so
        // we need to force canceling from here
        if (!e.get_response().get_aborted() && this.m_reallyCanceled)
        {
            this._cancelReportViewerLoading();
        }
    },

    _clearDelayTimer: function()
    {
        if (this.m_delayTimer != null)
        {
            clearTimeout(this.m_delayTimer);
            this.m_delayTimer = null;
        }
    },

    _clearPollingTimer: function()
    {
        if (this.m_visiblePollingTimer != null)
        {
            clearTimeout(this.m_visiblePollingTimer);
            this.m_visiblePollingTimer = null;
        }
    },

    _triggeringControlWasAsyncLoadTarget: function()
    {
        var eventTarget = this._postBackElement;

        if (eventTarget && eventTarget.id.indexOf("Reserved_AsyncLoadTarget") >= 0)
        {
            return true;
        }

        return false;
    },

    _areRelated: function(ancestor, descendant)
    {
        // using the overload of $get to see if descendant is a descendant of ancestor
        // this is equivalent to ancestor.getElementById(descendant.id)
        // it will return null if $get fails to find descendant under ancestor
        return ancestor && descendant && (ancestor == descendant || _$RVCommon.getPostBackTargetElementById(descendant.id, ancestor));
    },

    _triggeringControlWasForThisViewer: function()
    {
        var eventTarget = this._postBackElement;

        // If the postback came from something registered in our triggers list, then we are interested
        // in it and should react by doing things like showing async spinny.
        // The viewer itself is registered in this list, so it doesn't need a special case here.

        if (eventTarget)
        {
            var triggerIds = this.get_TriggerIds();
            for (var i = 0; i < triggerIds.length; ++i)
            {
                var ancestor = $get(triggerIds[i]);

                if (this._areRelated(ancestor, eventTarget))
                {
                    return true;
                }
            }
        }

        return false;
    },

    _onReportViewerLoadingChanged: function(sender, e)
    {
        if (e.get_propertyName() == "isLoading")
        {
            var isLoading = this.m_reportViewer.get_isLoading();

            if (!isLoading)
            {
                // If a viewer is about to trigger a postback, don't hide the transparency
                // Explicitly check for true to force passing in a boolean to 
                var showTrans = Microsoft.Reporting.WebFormsClient._ReportAreaAsyncLoadTarget.AsyncTriggerSelected == true;

                // hide the async wait control
                this.set_visible(showTrans, false);
                this._clearDelayTimer();
                this._clearPollingTimer();
            }
            else
            {
                // the control will tell spinny to dislay immediately if this
                // is the first time a report is being rendered
                if (this.SkipTimer)
                {
                    this.SkipTimer = false;
                    this._onDelayStartTimerCompleted();
                }
                else
                {
                    this.m_delayTimer = setTimeout(this.m_delayTimerCompletedDelegate, this.DisplayDelay);
                }
            }
        }
    },

    _onDelayStartTimerCompleted: function()
    {
        this.set_visible(true, this._triggeringControlWasForThisViewer());
    },

    set_visible: function(transVisible, waitVisible)
    {
        /// <summary>
        /// This is the "public" entry point to hiding/showing spinny.
        /// The other methods: _start_visibility_polling and _set_visible_core should not
        /// be directly called.
        ///
        /// Here we just record what the current state of spinny should be, and then
        /// kick off the polling
        /// </summary>

        this.m_transVisible = transVisible;
        this.m_waitVisible = waitVisible;

        this._start_visibility_polling();
    },


    _start_visibility_polling: function()
    {
        this._set_visible_core();

        // set a timer that will check and position spinny on a regular interval
        // this accounts for if the user resizes the window with spinny showing when
        // the layout uses percentages. A timer is necessary instead of listening to the
        // resize event because IE does not always fire the event. For simplicity, it was decided
        // to use the timer for all browsers, as using the resize event in Firefox/Safari didn't buy
        // enough to warrant the multiple code paths
        if (this.m_reportViewer.get_isLoading())
        {
            // this value influences how this action behaves
            // longer timeout = smoother overall, but spinny stays in the wrong place longer
            // shorter timeout = jerkier, but spinny stays in the wrong place shorter
            // 200 millis seemed about the best compromise between the two on a modern machine
            var timeoutMillis = 200;

            this.m_visiblePollingTimer = setTimeout(Function.createDelegate(this, this._start_visibility_polling), timeoutMillis);
        }
    },

    _set_visible_core: function()
    {
        var transVisible = this.m_transVisible;
        var waitVisible = this.m_waitVisible;

        var element = this.get_element();

        // This is to position spinny correctly in the case of the viewer placed in a non-static
        // element. See the method below for more details
        var anchoringParentOffset = this._getAnchoringParentOffsets(element);

        if (transVisible)
        {
            var dims = this._getBounds();

            element.style.top = (dims.top - anchoringParentOffset.top) + "px";
            element.style.left = (dims.left - anchoringParentOffset.left) + "px";
            element.style.width = dims.width + "px";
            element.style.height = dims.height + "px";
        }

        element.style.zIndex = 1000;
        this.m_waitControl.style.zIndex = 1001;

        Sys.UI.DomElement.setVisible(element, transVisible);
        Sys.UI.DomElement.setVisible(this.m_waitControl, waitVisible);

        if (transVisible)
        {
            this._clip(element);
        }

        if (waitVisible)
        {
            var centering = this._getTopLeftForCenter(this.m_waitControl);
            this.m_waitControl.style.top = (centering.top - anchoringParentOffset.top) + "px";
            this.m_waitControl.style.left = (centering.left - anchoringParentOffset.left) + "px";

            this._clip(this.m_waitControl);
        }
    },

    _getAnchoringParentOffsets: function(element)
    {
        /// <summary>
        /// This method acquires the element's nearest offset parent's offsets
        /// from the window. This is used to position spinny correctly.
        /// </summary>
        ///
        /// <remarks>
        /// If the viewer is placed in an absolute, fixed or relative element,
        /// then spinny (who is position:absolute) will get its positioning
        /// anchored off of that element. The normal course of things is to determine
        /// where spinny should go relative to the window, then position it with those values
        /// but if spinny has an offset parent, it will get positioned off of that parent and not
        /// the window, causing spinny to be too far to the left and too far down. This method
        /// determines that element's offset, and we use these values to subtract spinny's ultimate
        /// position, to account for this.
        ///
        /// NOTES: this method must move up the parentNode hierarchy and not the offsetParent hierarchy
        /// because Safari and Firefox both do not consider a fixed element to be in the offset hierarchy,
        /// even though spinny will get anchored off of them
        ///
        /// We don't care about whether an ancestor has overflow or not because we are positioning off
        /// of the ancestor's upper corner, where the overflow is irrelevant. the _clip() method below
        /// will deal with overflow issues in order to clip spinny accordingly
        /// </remarks>



        var top = 0;
        var left = 0;

        if (element)
        {
            var node = element.parentNode;

            while (node && node.style != undefined && !this.HasAnchoringPositionStyle(node))
            {
                node = node.parentNode;
            }

            if (node && node.style != undefined)
            {
                var offset = _$RVCommon.documentOffset(node);
                top = offset.top;
                left = offset.left;
            }

            // Now we need to deal with the anchoring node's borders. This is handled
            // differently for the body versus any other element, and also handled differently by browser mode

            // we purposely skipped the body in the while loop above. If the anchoring element really is the body,
            // we need to handle it as a special case, instead of the standard case above. We deal with body below.
            // So if we made it all the way up to document, then really the body is what we are interested in 
            // for the remainder of the method.
            if (node == document)
            {
                node = document.body;
            }

            // NOTE: "borderTopWidth" does not work in Firefox/Safari, but "border-top-width" works in everything
            var borderTopWidth = _$RVCommon.getInt(_$RVCommon.getComputedStyle(node, "border-top-width"));
            var borderLeftWidth = _$RVCommon.getInt(_$RVCommon.getComputedStyle(node, "border-left-width"));

            if (node == document.body && !_$RVCommon.isPreIE8StandardsMode() && !_$RVCommon.isIEQuirksMode())
            {
                // IE8 standards, Firefox and Safari will cause our offsets to be off by the body's border size,
                // so we need to adjust for that. For quirks mode, this is not needed

                top -= borderTopWidth;
                left -= borderLeftWidth;
            }
            else if (node != document.body)
            {
                // for non body nodes in all browsers, we need to take their borders into account
                top += borderTopWidth;
                left += borderLeftWidth;
            }
        }

        return { top: top, left: left };
    },

    HasAnchoringPositionStyle: function(element)
    {
        // we don't want body to be considered in this method. for body, we basically want this
        // method to return false, because body is a special case in regards to margins, padding and borders
        // see above in _getAnchoringParentOffsets how we handle body.

        // Retrieve the CSS positioning style for a given node.  This method takes into account
        // positioning that is set via a style sheet in addition to inline styles.
        // The currentStyle property is supported by IE. Other browsers (Firefox, Safari) must use the
        // getComputedStyle method.
        var positionStyle = "";
        if (element.currentStyle != null)
            positionStyle = element.currentStyle.position;
        else if (window.getComputedStyle != null)
        {
            var cs = window.getComputedStyle(element, null);
            positionStyle = cs.getPropertyValue('position');
        }

        return positionStyle == "fixed" || positionStyle == "absolute" || positionStyle == "relative";
    },

    _clip: function(element)
    {
        /// <summary>
        /// Ensures the given element doesn't extend beyond a constraining parent
        /// </summary>


        // find a parent that has constrained its children's visibility with overflow
        // two parentNodes here because the first one is the updatepanel of the viewer
        var parent = $get(this.ReportViewerId).parentNode.parentNode;

        while (parent && this._hasNoOverflowSet(parent))
        {
            parent = parent.parentNode;
        }

        // if found one, set this element's clip to ensure it
        // does not go out beyond its parent
        if (parent)
        {
            var pbounds = _$RVCommon.getBounds(parent);
            var ebounds = _$RVCommon.getBounds(element);

            if (parent.scrollWidth > parent.clientWidth
                && parent.style.overflow != "hidden"
                && parent.style.overflowX != "hidden"
                && !_$RVCommon.isSafari()) // safari already accounts for scrollbars when reporting sizes
            {
                // has horizontal scrollbar
                pbounds.height -= 18;
                pbounds.bottom -= 18;
            }

            if (parent.scrollHeight > parent.clientHeight
                && parent.style.overflow != "hidden"
                && parent.style.overflowY != "hidden"
                && !_$RVCommon.isSafari())  // safari already accounts for scrollbars when reporting sizes
            {
                // has vertical scrollbar
                pbounds.width -= 18;
                pbounds.right -= 18;
            }

            var topClip = ebounds.top < pbounds.top ? pbounds.top - ebounds.top : 0;
            var leftClip = ebounds.left < pbounds.left ? pbounds.left - ebounds.left : 0;

            var bottomClip = ebounds.height - (ebounds.bottom - pbounds.bottom);
            var rightClip = ebounds.width - (ebounds.right - pbounds.right);

            // rect(top, right, bottom, left)
            // clip works non-intuitively. top and left define the upper left corner of the clipping rectangle
            // relative to the element. bottom and right define the bottom right corner, relative
            // to the element. It doesn't work like padding and margin do.
            var clip = "rect(" + topClip + "px," + rightClip + "px," + bottomClip + "px," + leftClip + "px)";
            element.style.clip = clip;
        }
    },

    _hasNoOverflowSet: function(element)
    {
        if (
        (element == null)
            ||
            (element.style == undefined)
            ||
            (
            element.style.overflow != "hidden"
            && element.style.overflow != "scroll"
            && element.style.overflow != "auto"
            && element.style.overflowX != "hidden"
            && element.style.overflowX != "scroll"
            && element.style.overflowX != "auto"
            && element.style.overflowY != "hidden"
            && element.style.overflowY != "scroll"
            && element.style.overflowY != "auto"
            )
        )
        {
            return true;
        }
        else
        {
            return false;
        }
    },

    _getTopLeftForCenter: function(element)
    {
        var dims = this._getBounds();
        var elemDims = _$RVCommon.getBounds(element);

        var top = dims.top + dims.height / 2.0 - elemDims.height / 2.0;
        var left = dims.left + dims.width / 2.0 - elemDims.width / 2.0;


        // clamp async spinny within the bounds of the viewer
        // basically we are saying nothing the viewer produces (ie spinny)
        // will invade above or just behind in the document, for below and
        // just ahead in the document, we make no promise
        var isRtl = this.m_reportViewer._get_direction() == "rtl";

        if (isRtl)
        {
            var elementRight = left + elemDims.width;
            var viewerRight = dims.left + dims.width;
            if (elementRight > viewerRight)
            {
                left -= elementRight - viewerRight;
            }
        }
        else if (left < 0)
        {
            left = 0;
        }


        if (top < 0)
        {
            top = 0;
        }

        return { top: top, left: left };
    },

    _getBounds: function()
    {
        var fixedTable = $get(this.FixedTableId);

        var offsets = _$RVCommon.documentOffset(fixedTable);
        var top = offsets.top;
        var left = offsets.left;

        var lastRow = fixedTable.rows.item(fixedTable.rows.length - 1);

        top += fixedTable.clientHeight - lastRow.offsetHeight;

        return { left: left, top: top, width: fixedTable.clientWidth, height: lastRow.offsetHeight };
    }
}

Microsoft.Reporting.WebFormsClient._AsyncWaitControl.registerClass("Microsoft.Reporting.WebFormsClient._AsyncWaitControl", Sys.UI.Control);
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Type.registerNamespace("Microsoft.Reporting.WebFormsClient");

Microsoft.Reporting.WebFormsClient._DocMapArea = function(element)
{
    Microsoft.Reporting.WebFormsClient._DocMapArea.initializeBase(this, [element]);

    this.RootNodeId = null;
    this.SelectedNodeHiddenFieldId = null;
    this.TriggerPostBack = null;
    this.IsLTR = true;
    this.ReportViewerId = null;

    this.m_active = true;
    this.m_selectedNode = null;
    this.m_originalTextNodeColor = null;
    this.m_originalTextNodeBackColor = null;
}

Microsoft.Reporting.WebFormsClient._DocMapArea.prototype =
{
    initialize: function()
    {
        Microsoft.Reporting.WebFormsClient._DocMapArea.callBaseMethod(this, "initialize");
        
        if (this.RootNodeId != null)
        {
            this.SetDirectionForTree();
            
            var rootNode = $get(this.RootNodeId);
            var textNode = this.GetTextNodeFromTreeNode(rootNode);

            // Save the original text node color and back color
            this.m_originalTextNodeColor = textNode.style.color;
            if (this.m_originalTextNodeColor == null)
                this.m_originalTextNodeColor = "";                
            this.m_originalTextNodeBackColor = textNode.style.backgroundcolor;
            if (this.m_originalTextNodeBackColor == null)
                this.m_originalTextNodeBackColor = "";

            this.MarkNodeAsSelected(rootNode);
        }
    },

    dispose: function()
    {
        Microsoft.Reporting.WebFormsClient._DocMapArea.callBaseMethod(this, "dispose");
        this.m_selectedTextNode = null;
    },

    SetActive: function(active)
    {
        this.m_active = active;
    },

    ExpandCollapseNode : function(treeNode)
    {
        if (!this.m_active)
            return;

        var wasExpanded = this.IsNodeExpanded(treeNode);

        // Toggle visibility on the child nodes and images.  Only toggle immediate children
        var childNodes = treeNode.childNodes;
        for (var i = 0; i < childNodes.length; i++)
        {
            var childNode = childNodes[i];
            if (childNode.tagName === "DIV" ||  // Child nodes
                childNode.tagName === "INPUT")  // Expand/collapse images
            {
                this.ToggleNodeVisibility(childNode);
            }
        }
        
        // If the node is being collapsed and the currently selected node is a child
        // of that node, move the selection to the parent
        if (wasExpanded)
        {
            var allChildren = treeNode.getElementsByTagName("div");
            for (var i = 0; i < allChildren.length; i++)
            {
                if (allChildren[i] == this.m_selectedNode)
                {
                    this.MarkNodeAsSelected(treeNode);
                    break;
                }
            }
        }
    },

    IsNodeExpanded : function(treeNode)
    {
        // Look for a visible child tree node (DIV)
        var childNodes = treeNode.childNodes;
        for (var i = 0; i < childNodes.length; i++)
        {
            var childNode = childNodes[i];
            
            if (childNode.tagName === "DIV")
                return childNode.style.display !== "none";
        }
        
        // Leaf node
        return true;
    },
    
    IsLeafNode : function(treeNode)
    {
        var childNodes = treeNode.getElementsByTagName("DIV");
        return childNodes.length === 0;
    },
    
    ToggleNodeVisibility : function(node)
    {
        var isCurrentlyVisible = node.style.display !== "none";            
        _$RVCommon.SetElementVisibility(node, !isCurrentlyVisible);
    },
    
    OnTextNodeEnter : function(textNode)
    {
        if (!this.IsTextNodeSelected(textNode))
        {
            textNode.style.color = "highlighttext";
            textNode.style.backgroundColor = "highlight";
        }
    },
    
    OnTextNodeLeave : function(textNode)
    {
        if (!this.IsTextNodeSelected(textNode))
        {
            textNode.style.color = this.m_originalTextNodeColor;
            textNode.style.backgroundColor = this.m_originalTextNodeBackColor;
        }
    },
    
    IsTextNodeSelected : function(textNode)
    {
        return this.m_selectedNode != null && textNode == this.GetTextNodeFromTreeNode(this.m_selectedNode);
    },
    
    OnAnchorNodeSelected : function(anchorNode)
    {
        this.OnTreeNodeSelected(anchorNode.parentNode);
    },
    
    OnTreeNodeSelected : function(treeNode)
    {
        var docMapId = treeNode.attributes.getNamedItem("DocMapId").value;
        this.MarkNodeAsSelected(treeNode);
        $get(this.SelectedNodeHiddenFieldId).value = docMapId;
        this.TriggerPostBack();
    },
    
    MarkNodeAsSelected : function(treeNode)
    {
        // Remove old selection
        if (this.m_selectedNode != null)
        {
            var selectedTextNode = this.GetTextNodeFromTreeNode(this.m_selectedNode);

            selectedTextNode.style.color = this.m_originalTextNodeColor;
            selectedTextNode.style.backgroundColor = this.m_originalTextNodeBackColor;

            this.m_selectedNode = null;
        }
        
        if (treeNode != null)
        {
            this.m_selectedNode = treeNode;
            
            var selectedTextNode = this.GetTextNodeFromTreeNode(treeNode);
            
            selectedTextNode.style.color = "highlighttext";
            selectedTextNode.style.backgroundColor = "highlight";
            
            try
            {
                selectedTextNode.focus();
                
                // Update scroll position.  Ensure the tree node is visible
                var scrollableDiv = treeNode.offsetParent;
                if (scrollableDiv.scrollTop > selectedTextNode.offsetTop)
                    scrollableDiv.scrollTop = selectedTextNode.offsetTop - 1; // -1 for just a little padding
                else if (scrollableDiv.scrollTop + scrollableDiv.offsetHeight < selectedTextNode.offsetTop + selectedTextNode.offsetHeight)
                    scrollableDiv.scrollTop = selectedTextNode.offsetTop + selectedTextNode.offsetHeight - scrollableDiv.offsetHeight + 1; // +1 for just a little padding
            }
            catch (e)
            {
                // focus will throw if the item can't get the focus (e.g. the node is hidden).
                // Since we are only setting focus to be consistent with the selection, this is
                // ok - if the user can't see the focus rectangle, it won't be inconsistent
            }
        }
    },
    
    GetTextNodeFromTreeNode : function(treeNode)
    {
        var anchorNode = treeNode.getElementsByTagName("a")[0];
        return anchorNode.getElementsByTagName("span")[0];
    },
    
    SetDirectionForTree : function()
    {
        // If the server rendered the incorrect direction, fix it.
        var reportViewer = $find(this.ReportViewerId);
        var direction = reportViewer._get_direction();
        if ((direction === "ltr" && !this.IsLTR) || (direction === "rtl" && this.IsLTR))
        {
            var docMapArea = this.get_element();

            // Swap the margins for each child tree node
            var childNodes = docMapArea.getElementsByTagName("DIV");
            for (var i = 0; i < childNodes.length; i++)
            {
                var treeNode = childNodes[i];
                
                var oldMarginRight = treeNode.style.marginRight;
                treeNode.style.marginRight = treeNode.style.marginLeft;
                treeNode.style.marginLeft = oldMarginRight;
            }

            this.IsLTR = !this.IsLTR;
        }
    },
    
    OnKeyDown : function(e)
    {
        if (!this.m_active)
            return;

        if (e.altKey == true)
            return;

        switch (e.keyCode)
        {
            case 187: //=
                if (!e.shiftKey)
                    break;

            case 107: //+
                if (!this.IsLeafNode(this.m_selectedNode) && !this.IsNodeExpanded(this.m_selectedNode))
                    this.ExpandCollapseNode(this.m_selectedNode);
                e.returnValue = false;
                break;

            case 189: //-
                if (e.shiftKey)
                    break;

            case 109: //-
                if (!this.IsLeafNode(this.m_selectedNode) && this.IsNodeExpanded(this.m_selectedNode))
                    this.ExpandCollapseNode(this.m_selectedNode);
                e.returnValue = false;
                break;

            case Sys.UI.Key.right:
                e.returnValue = false;
                if (!this.IsLeafNode(this.m_selectedNode))
                {
                    if (!this.IsNodeExpanded(this.m_selectedNode))
                        this.ExpandCollapseNode(this.m_selectedNode);
                    else
                    {
                        // Select the first child
                        var firstChild = this.m_selectedNode.getElementsByTagName("DIV")[0];
                        this.MarkNodeAsSelected(firstChild);
                    }
                }
                break;

            case Sys.UI.Key.down:
                // Find visible child
                if (!this.IsLeafNode(this.m_selectedNode) && this.IsNodeExpanded(this.m_selectedNode))
                {
                    var firstChild = this.m_selectedNode.getElementsByTagName("DIV")[0];
                    this.MarkNodeAsSelected(firstChild);
                }
                else
                {
                    // Find next sibling.  If no sibling, go up a level and look for a sibling there
                    var parent = this.m_selectedNode;
                    var rootNode = $get(this.RootNodeId);
                    while (parent != rootNode)
                    {
                        // Advance up the hierarchy
                        var nodeToFindNextSiblingOf = parent;
                        parent = parent.parentNode;

                        // Find the index of the current selected node                        
                        var children = parent.childNodes;
                        for (var i = 0; i < children.length; i++)
                        {
                            if (children[i] == nodeToFindNextSiblingOf)
                                break;
                        }

                        // Select the next sibling if this is not the last node                        
                        if (i + 1 < children.length)
                        {
                            this.MarkNodeAsSelected(children[i + 1]);
                            break;
                        }
                    }
                }
                e.returnValue = false;
                break;

            case Sys.UI.Key.left:
                if (this.IsLeafNode(this.m_selectedNode) || !this.IsNodeExpanded(this.m_selectedNode))
                {
                    // Move to parent node
                    if (this.m_selectedNode != $get(this.RootNodeId))
                        this.MarkNodeAsSelected(this.m_selectedNode.parentNode);
                }
                else
                {
                    // An expanded node - collapse it
                    this.ExpandCollapseNode(this.m_selectedNode);
                }
                e.returnValue = false;
                break;

            case Sys.UI.Key.up:
                if (this.m_selectedNode != $get(this.RootNodeId))
                {
                    var siblings = this.m_selectedNode.parentNode.childNodes;
                    
                    // Find the index of the current selected node                        
                    for (var i = 0; i < siblings.length; i++)
                    {
                        if (siblings[i] == this.m_selectedNode)
                            break;
                    }

                    // Find the immediately previous sibling to the selected node
                    if (i > 0 && siblings[i - 1].tagName === "DIV")
                    {
                        var previousSibling = siblings[i - 1];
                        
                        // If the previous sibling is expanded, find its last expanded child
                        var trav = previousSibling;
                        while (trav != null && !this.IsLeafNode(trav) && this.IsNodeExpanded(trav))
                        {
                            var travChildren = trav.childNodes;
                            for (var i = travChildren.length - 1; i >= 0; i--)
                            {
                                if (travChildren[i].tagName === "DIV")
                                {
                                    trav = travChildren[i];
                                    break;
                                }
                            }
                        }
                        
                        this.MarkNodeAsSelected(trav);
                    }
                    else
                        this.MarkNodeAsSelected(this.m_selectedNode.parentNode);
                }
                e.returnValue = false;
                break;

            case Sys.UI.Key.enter:
                this.OnTreeNodeSelected(this.m_selectedNode);
                e.returnValue = false;
                break;
        }
    }
}

Microsoft.Reporting.WebFormsClient._DocMapArea.registerClass("Microsoft.Reporting.WebFormsClient._DocMapArea", Sys.UI.Control);// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
function Microsoft_ReportingServices_HTMLRenderer_CalculateZoom(reportCellId)
{
    //Calculates zoom based on reportCellId zoom.  By default, it's 1 (or 100%)
    var zoom = 1;
    if (reportCellId)
    {
        var reportCell = document.getElementById(reportCellId);
        if (reportCell)
        {
            var zt = reportCell.style.zoom;
            if (zt && zt.substring(zt.length - 1) == '%')
            {
                zoom = zt.substring(0, zt.length - 1) / 100;
            }
            else
            {
                zoom = zt;
            }
            if (!zoom || zoom == 0) zoom = 1;
        }
    }
    return zoom;
}

function Microsoft_ReportingServices_HTMLRenderer_CalculateOffset(topElement, targetElement)
{
    //Calculates the top and left offset based on the topElement and targetElement
    var measureElement = targetElement;
    var divTop = 0;
    var divLeft = 0;
    while (measureElement && (!topElement || measureElement.id != topElement.id))
    {
        divTop += measureElement.offsetTop;
        divLeft += measureElement.offsetLeft;
        var offsetParent = measureElement.offsetParent;
        while (measureElement != offsetParent && (!topElement || measureElement.id != topElement.id))
        {
            measureElement = measureElement.parentNode;
        }
    }

    return { top: divTop, left: divLeft };
}

function Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode()
{
    return document.compatMode && document.compatMode != "BackCompat";
}

function Microsoft_ReportingServices_HTMLRenderer_IsIE()
{
    if (document.all)
        return true;
    return false;
}

function Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater()
{
    if (Microsoft_ReportingServices_HTMLRenderer_IsIE() && document.documentMode && document.documentMode >= 8)
        return true;
    return false;
}

function Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(size)
{
    var sizeString = size.toString();
    // Get the numeric value of the size measurement.
    // First set sizeValue to the sizeString. (assuming no units or length of size
    // < 2).

    var sizeValue = parseFloat(sizeString);

    if (isNaN(sizeValue))
    {
        sizeValue = 0;
    }

    // Now try to parse out the sizeValue and the sizeUnit
    if ((sizeString.length >= 2) && (sizeValue > 0))
    {
        sizeValue = parseFloat(sizeString.substring(0, sizeString.length - 2));
        // Get the unit type of the size measurement.
        var sizeUnit = sizeString.substring(sizeString.length - 2, sizeString.length);

        var dpi = Microsoft_ReportingServices_HTMLRenderer_PxPerInch();

        switch (sizeUnit)
        {
            case "mm":
                sizeValue = sizeValue * dpi / 25.4;
                break;
            case "pt":
                sizeValue = sizeValue * dpi / 72;
                break;
            case "in":
                sizeValue = sizeValue * dpi;
                break;
            case "cm":
                sizeValue = sizeValue * dpi / 2.54;
                break;
            case "px":
                sizeValue = sizeValue;
                break;
            default:
                // No units specified, just use the sizeString.
                sizeValue = parseFloat(sizeString);
                break;
        }
    }
    return sizeValue;
}

function Microsoft_ReportingServices_HTMLRenderer_PxPerInch()
{
    var div = document.createElement("div");
    div.id = "fakeDPIDiv";
    div.style.cssText = "width:72pt; height:0pt; display:hidden; position:absolute; z-index:-1; font-size: 0pt; top:0px; left:0px";
    document.body.appendChild(div);
    var width = div.style.pixelWidth;
    if (!width)
    {
        width = div.offsetWidth;
    }
    document.body.removeChild(div);
    dpi = width;
    return dpi;
}

function Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, styleProp)
{
    var retVal = null;

    if (element.currentStyle)
    {
        retVal = element.currentStyle[styleProp];
    }
    else
    {
        var computedStyle = window.getComputedStyle(element, null);
        retVal = computedStyle[styleProp];
    }

    return retVal;
}

function Microsoft_ReportingServices_HTMLRenderer_GetFirstChildElementNode(element)
{
    var firstChildNode = null;
    var childElements = element.childNodes;
    for (var i = 0; i < childElements.length; i++)
    {
        var child = childElements[i];
        if (child.nodeType == 1)
        {
            // nodeType = 1 denotes an element node.
            firstChildNode = child;
            break;
        }
    }
    return firstChildNode;
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalBorders(element, width)
{
    var borderLeftWidth = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "borderLeftWidth");

    if (borderLeftWidth)
    {
        width = width - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(borderLeftWidth);
    }

    var borderRightWidth = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "borderRightWidth");

    if (borderRightWidth)
    {
        width = width - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(borderRightWidth);
    }

    return width;
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalPaddings(element, width)
{
    var paddingLeft = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "paddingLeft");

    if (paddingLeft)
    {
        width = width - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(paddingLeft);
    }

    var paddingRight = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "paddingRight");

    if (paddingRight)
    {
        width = width - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(paddingRight);
    }

    return width;
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalBordersPaddings(element)
{
    // This function should currently only be called in FitProportional.js when the following below
    // condition is true: Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode() && Microsoft_ReportingServices_HTMLRenderer_IsIE()
    var width = Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(element.currentStyle.width);

    width = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalBorders(element, width);

    width = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalPaddings(element, width);

    if (width <= 0)
    {
        // Don't allow a negative sizing to be returned.
        width = 1;
    }

    return width.toString() + "px";
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalBorders(element, height)
{
    var borderTopWidth = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "borderTopWidth");

    if (borderTopWidth)
    {
        height = height - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(borderTopWidth);
    }

    var borderBottomWidth = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "borderBottomWidth");

    if (borderBottomWidth)
    {
        height = height - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(borderBottomWidth);
    }

    return height;
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalPaddings(element, height)
{
    var paddingTop = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "paddingTop");

    if (paddingTop)
    {
        height = height - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(paddingTop);
    }

    var paddingBottom = Microsoft_ReportingServices_HTMLRenderer_GetStyle(element, "paddingBottom");

    if (paddingBottom)
    {
        height = height - Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(paddingBottom);
    }

    return height;
}

function Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalBordersPaddings(element)
{
    // This function should currently only be called in FitProportional.js when the following below
    // condition is true: Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode() && Microsoft_ReportingServices_HTMLRenderer_IsIE()
    var height = Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(element.currentStyle.height);

    height = Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalBorders(element, height);

    height = Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalPaddings(element, height);

    if (height <= 0)
    {
        // Don't allow a negative sizing to be returned.
        height = 1;
    }

    return height.toString() + "px";
}

function Microsoft_ReportingServices_HTMLRenderer_GetMaxChildRowSpan(row)
{
    var maxRowSpan = 1;
    var i = 0;

    // Bug only occurs (setting heights of <tr> elements in IE8 standards mode).
    if (Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater() &&
        Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode())
    {
        // This function should only apply its logic when row is a <TR> element.
        if (row.nodeName == "TR")
        {
            if (row.childNodes)
            {
                for (i = 0; i < row.childNodes.length; i++)
                {
                    var rowChildNode = row.childNodes[i];
                    var rowSpan = rowChildNode.getAttribute("rowSpan");
                    if (rowSpan)
                    {
                        rowSpan = parseInt(rowSpan);
                        if (rowSpan > maxRowSpan)
                        {
                            maxRowSpan = rowSpan;
                        }
                    }
                }
            }
        }
    }
    return maxRowSpan;
}

function Microsoft_ReportingServices_HTMLRenderer_GrowRectangles(prefixId, reportDivID)
{
    // This function is used to grow rectangles to fits its contents which could potentially get clipped
    // (in IE) when growth (due to text-wrapping, etc...) occurs.
    if (Microsoft_ReportingServices_HTMLRenderer_IsIE())
    {
        var isStandardsMode = Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode();
        var isIE8OrLater = Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater();
        
        var growRectIdsTagId = "growRectangleIdsTag";
        if (prefixId)
        {
            growRectIdsTagId = prefixId + growRectIdsTagId;
        }
        
        var growRectIdsTag = document.getElementById(growRectIdsTagId);
        if (growRectIdsTag)
        {
            var idsString = growRectIdsTag.getAttribute("ids");
            if (idsString)
            {
                var ids = idsString.split(",");
                // Need to grow childNode rectangles in DOM before parentNode rectangles.
                for (var i = ids.length - 1; i >= 0; i--)
                {
                    var id = ids[i];
                    if ((id) && (id != ""))
                    {
                        var div = document.getElementById(id);
                        if (div)
                        {
                            if (!isStandardsMode)
                            {
                                // In IE quirks mode, if the contents of the rectangle outgrows the rectangle,
                                // no clipping occurs, and the clientWidth of the rectangle DIV is the same
                                // as its child contents, but no horizontal srollbars appear even though the contents
                                // overflow the screen. To get the scrollbar to appear as desired, set the style width
                                // of the rectangle DIV to be its client dimensions (esp. width) in pixels.
                                if (div.clientWidth > 0)
                                {
                                    div.style.width = div.clientWidth + "px";
                                }

                                if (div.clientHeight > 0)
                                {
                                    div.style.height = div.clientHeight + "px";
                                }
                            }

                            // In IE7 standards mode, a tablix (or any other report item)
                            // that outgrows its rectangular container will have its contents clipped.
                            // In IE8 standards mode, a rectangle with its contents (i.e. image) outgrowing it will not
                            // grow to fit its contents. Instead, the image will grow and appear outside of the rectangle
                            // boundaries, within the DOM. However, the page will look okay.

                            var childNode = div.firstChild;

                            // If the child is also a rectangle, look for the first non-rectangular child.
                            while ((childNode != null) && (childNode.tagName == "DIV") && (childNode.getAttribute("growRect")))
                            {
                                childNode = childNode.firstChild;
                            }

                            if (childNode != null)
                            {
                                if (childNode.clientWidth > div.clientWidth)
                                {
                                    div.style.width = childNode.clientWidth + "px";
                                }

                                if (childNode.clientHeight > div.clientHeight)
                                {
                                    div.style.height = childNode.clientHeight + "px";
                                }
                            }
                        }
                    }
                }
            }            
        }       
    }
}

function Microsoft_ReportingServices_HTMLRenderer_FitVertText(prefixId, reportDivID)
{
    var fitVertTextIdsTagId = "fitVertTextIdsTag";
    if (prefixId)
    {
        fitVertTextIdsTagId = prefixId + fitVertTextIdsTagId;
    }
    
    var fitVertTextIdsTag = document.getElementById(fitVertTextIdsTagId);
    if (fitVertTextIdsTag)
    {
        var idsString = fitVertTextIdsTag.getAttribute("ids");
        if (idsString)
        {
            var ids = idsString.split(",");
            for (var i = 0; i < ids.length; i++)
            {
                var id = ids[i];
                if ((id) && (id != ""))
                {
                    var div = document.getElementById(id);
                    if (div)
                    {
                        if (div.clientWidth < div.firstChild.clientWidth)
                        {
                            div.style.width = div.firstChild.clientWidth + "px";
                        }

                        if (div.clientHeight < div.firstChild.clientHeight)
                        {
                            div.style.height = div.firstChild.clientHeight + "px";
                        }

                        if (div.clientWidth > div.parentNode.clientWidth)
                        {
                            // If a lot of breaking vertical characters causes vertical text
                            // the vertical textbox inside of tablix to render outside its tablix
                            // cell, set the textbox's client dimensions to the tablix cell dimensions
                            // and change display to block.
                            div.style.width = div.parentNode.clientWidth + "px";
                            div.style.height = div.parentNode.clientHeight + "px";
                            div.style.display = "block";
                        }
                    }
                }
            }
        }
    }
}
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
//FitProportional
Microsoft_ReportingServices_HTMLRenderer_FitProportional = function()
{
}
Microsoft_ReportingServices_HTMLRenderer_FitProportional.prototype =
{
    ResizeImage: function(o, reportDiv, reportCellId)
    {

        if (!o) return; var op = o.parentNode; if (!op) return;
        var width = o.width;
        var height = o.height;
        var target = o;
        var parentDiv = op;
        var isIE7OrLess = false;
        if (op.tagName == 'A') //If the parent is an A-tag, get the div containing
        {
            op = op.parentNode;
            parentDiv = op;
        }

        var stdMode = Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode();
        var isIE7OrLess = false;
        if (stdMode)
        {
            if (Microsoft_ReportingServices_HTMLRenderer_IsIE() &&
            !Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater())
            {
                isIE7OrLess = true;
            }
        }

        if (stdMode && Microsoft_ReportingServices_HTMLRenderer_IsIE())
        {
            if (parentDiv.getAttribute("alreadyResized") == null)
            {
                if (parentDiv.currentStyle.minWidth)
                {
                    if (parentDiv.clientWidth > Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(parentDiv.currentStyle.minWidth) + 1)
                    {
                        var adjustedMinWidth = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalBordersPaddings(parentDiv);
                        parentDiv.style.minWidth = adjustedMinWidth;

                    }
                }

                if (isIE7OrLess)
                {
                    if (parentDiv.currentStyle.width)
                    {
                        if (parentDiv.clientWidth > Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(parentDiv.currentStyle.width) + 1)
                        {
                            var adjustedWidth = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalBordersPaddings(parentDiv);
                            parentDiv.style.width = adjustedWidth;

                        }
                    }

                    if (parentDiv.currentStyle.height)
                    {
                        if (parentDiv.clientHeight > Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(parentDiv.currentStyle.height) + 1)
                        {
                            var adjustedHeight = Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalBordersPaddings(parentDiv);
                            parentDiv.style.height = adjustedHeight;

                        }
                    }
                }
                parentDiv.setAttribute("alreadyResized", "true");
            }
        }

        var scaleOffset = 1; //Matching previous behavior
        var useConsolidation = false;
        var repositionTopLeft = false;
        var zoom = 1;
        var resizeWithZoom = false;
        if (op.tagName == 'DIV' && op.getAttribute("imgConFitProp")) //ImageConsolidation, FitProportional
        {
            target = op;

            height = parseInt(op.style.height);
            width = parseInt(op.style.width);

            op = op.parentNode;

            scaleOffset = 0;
            useConsolidation = true;

            if (stdMode &&
                Microsoft_ReportingServices_HTMLRenderer_IsIE() &&
                isIE7OrLess)
            {
                if (target.style.position != "absolute")
                {
                    target.style.position = "absolute";
                }

                zoom = Microsoft_ReportingServices_HTMLRenderer_CalculateZoom(reportCellId);

                if (op.getAttribute("origHeight"))
                    height = op.getAttribute("origHeight");
                else
                    op.setAttribute("origHeight", height);

                if (op.getAttribute("origWidth"))
                    width = op.getAttribute("origWidth");
                else
                    op.setAttribute("origWidth", width);

                resizeWithZoom = true;
            }
        }

        if ((o.width != 0) && (o.height != 0) && op)
        {
            var oHeight = o.height;
            var oWidth = o.width;

            if (o.naturalHeight) //Always use the actual image sizing information, if available
            {
                oHeight = o.naturalHeight;
                oWidth = o.naturalWidth;
                if (!useConsolidation)
                {
                    height = oHeight;
                    width = oWidth;
                }
            }
            else if (o.width == 1 && o.height == 1 && !useConsolidation)
            {
                //Calculate the base image size by creating another and retrieving the sizing
                //Not Supported in IE6
                var tmpImage = new Image();
                tmpImage.src = o.src;
                oHeight = tmpImage.height;
                oWidth = tmpImage.width;
                height = oHeight;
                width = oWidth;
            }

            if (resizeWithZoom)
            {
                if (o.getAttribute("origHeight"))
                    oHeight = o.getAttribute("origHeight");
                else
                    o.setAttribute("origHeight", oHeight);

                if (o.getAttribute("origWidth"))
                    oWidth = o.getAttribute("origWidth");
                else
                    o.setAttribute("origWidth", oWidth);
            }

            var opHeight = op.clientHeight;
            var opWidth = op.clientWidth;
            //If parent size is larger than the item containing the FitProportional Image, use the larger size
            if (o.clientHeight == op.clientHeight && op.parentNode && op.parentNode.clientHeight >= o.clientHeight)
            {
                opHeight = op.parentNode.clientHeight;
                if (op.parentNode.nodeName == 'TD' && op.parentNode.parentNode.clientHeight > opHeight)
                    opHeight = op.parentNode.parentNode.clientHeight;
                opWidth = op.parentNode.clientWidth;
            }
            var dy = (opHeight + scaleOffset - o.pv) / height;
            var dx = (opWidth + scaleOffset - o.ph) / width;
            var dz = Math.min(dx, dy);
            var targetHeight = oHeight * dz * zoom;
            var targetWidth = oWidth * dz * zoom;
            if (useConsolidation)
            {
                if (targetHeight > 0)
                    o.height = targetHeight;

                if (width && targetWidth > 0)
                    o.width = targetWidth;

                if (height > 0 && dz > 0)
                    parentDiv.style.height = (height * dz * zoom) + "px";

                if (width > 0 && dz > 0)
                    parentDiv.style.width = (width * dz * zoom) + "px";

                //Offset based on the original value
                var origLeft = parseInt(o.style.left);
                var origTop = parseInt(o.style.top);

                var parentTop = 0;
                var parentLeft = 0;

                if (resizeWithZoom)
                {
                    //IE7 cannot use the relative coordinates, so the parentDiv is positioned
                    var offsets = Microsoft_ReportingServices_HTMLRenderer_CalculateOffset(reportDiv, op);
                    parentLeft = offsets.left;
                    parentTop = offsets.top;

                    if (o.getAttribute("origTop"))
                        origTop = parseInt(o.getAttribute("origTop"))
                    else
                        o.setAttribute("origTop", parseInt(o.style.top));
                    if (o.getAttribute("origLeft"))
                        origLeft = parseInt(o.getAttribute("origLeft"));
                    else
                        o.setAttribute("origLeft", parseInt(o.style.left));

                    o.style.top = (origTop * zoom) + "px";
                    o.style.left = (origLeft * zoom) + "px";
                }

                if (!isIE7OrLess)
                {
                    // Absolute positioning in IE8 standards mode/firefox puts items not relative to
                    // their container. Need to set parentDiv position style back to relative.
                    parentDiv.style.position = "relative";
                }

                var oCurrentLeft = parseInt(o.style.left);
                var oCurrentTop = parseInt(o.style.top);
                if (oCurrentLeft != null)
                {
                    o.style.left = parseInt(oCurrentLeft * dz) + "px";
                }
                if (oCurrentTop != null)
                {
                    o.style.top = parseInt(oCurrentTop * dz) + "px";
                }
                parentDiv.style.left = (parentLeft * zoom) + "px";
                parentDiv.style.top = (parentTop * zoom) + "px";
            }
            else
            {
                //Use the calculated size if it doesn't cause the parent to grow
                if (targetHeight > opHeight)
                    targetHeight = opHeight;
                if (targetWidth > opWidth)
                    targetWidth = opWidth;

                o.height = targetHeight;
                if (width) o.width = targetWidth;
            }
        }
    },
    ResizeImages: function(reportDivId, reportCellId)
    {
        var reportDiv = document.getElementById(reportDivId);
        while (reportDiv)
        {
            if (reportDiv.tagName == 'DIV')
            {
               var images = reportDiv.getElementsByTagName("IMG");
               for (var i = 0; i < images.length; i++)
               {
                   var o = images[i];
                   if (o.fitproportional && o.complete && !o.errored)
                       this.ResizeImage(o, reportDiv, reportCellId);
               }
            }
            reportDiv = reportDiv.nextSibling;
        }
    },
    PollResizeImages: function(reportDivId, reportCellId)
    {
        var reportDiv = document.getElementById(reportDivId);
        if (reportDiv)
        {
            var images = reportDiv.getElementsByTagName("IMG");
            for (var i = 0; i < images.length; i++)
            {
                var o = images[i];
                if (!o.complete && !o.errored)
                {
                    setTimeout('this.PollResizeImages(' + escape(reportDivId) + ',' + escape(reportDivId) + ')', 250);
                    return;
                }
            }
            this.ResizeImages(reportDivId);
        }
    }
}
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
Microsoft_ReportingServices_HTMLRenderer_FixedHeader = function(ReportDivId, ReportCellId, ContainerId, IDPrefix)
{
    this.ReportCellId = ReportCellId;
    this.ReportDivId = ReportDivId;
    this.ContainerId = ContainerId;
    if (!IDPrefix)
        IDPrefix = "";
    this.IDPrefix = IDPrefix;
}
Microsoft_ReportingServices_HTMLRenderer_FixedHeader.prototype =
{
    CreateFixedRowHeader: function(arr, id)
    {
        var tableID = arr[0];
        if (document.getElementById(this.IDPrefix + id))
            return;
        var tNode = document.getElementById(this.IDPrefix + tableID);
        if (tNode == null)
            return;
        tNode = tNode.cloneNode(false);
        tNode.removeAttribute('id');
        var tBodyNode = document.createElement("TBODY");
        var currentRow = document.getElementById(this.IDPrefix + arr[1]);
        currentRow = currentRow.cloneNode(false);
        currentRow.removeAttribute('id');
        for (var x = 2; x < arr.length; x++)
        {
            var nextElement = document.getElementById(this.IDPrefix + arr[x]);
            if (nextElement.tagName.toUpperCase() == "TR")
            {
                nextElement = nextElement.cloneNode(false);
                nextElement.removeAttribute('id');
                tBodyNode.appendChild(currentRow);
                currentRow = nextElement;
            } else
            {
                nextElement = nextElement.cloneNode(true);
                nextElement.removeAttribute('id');
                currentRow.appendChild(nextElement);
            }
        }
        tBodyNode.appendChild(currentRow);
        tNode.appendChild(tBodyNode);
        var parentDiv = document.createElement("DIV");
        parentDiv.style.display = 'none';
        parentDiv.style.position = 'absolute';
        parentDiv.style.top = "0px";
        parentDiv.style.left = "0px";
        parentDiv.id = this.IDPrefix + id;
        parentDiv.appendChild(tNode);
        var reportDiv = document.getElementById(this.ReportCellId);
        reportDiv.appendChild(parentDiv);
        return parentDiv;
    },
    CreateFixedColumnHeader: function(arr, id)
    {
        var tableID = arr[0];
        if (document.getElementById(this.IDPrefix + id))
            return;
        var tNode = document.getElementById(this.IDPrefix + tableID);
        if (tNode == null)
            return;
        var tNodeOrigWidth = 0;
        if ((tNode.tagName == "TABLE") &&
            Microsoft_ReportingServices_HTMLRenderer_IsIE() &&
            !Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode())
        {
            // If we're in IE Quirks mode, save the original column width which enforces a particular text wrapping
            // behavior.
            // tNode is a TABLE tag, so its first contained TD is the firstChild (TD) of its firstChild (TR) of its firstChild (TBODY).        
            var tNodeTDStyleWidth = tNode.firstChild.firstChild.firstChild.style.width;
            tNodeOrigWidth = Math.round(Microsoft_ReportingServices_HTMLRenderer_ConvertToPx(tNodeTDStyleWidth));
        }
        tNode = tNode.cloneNode(false);
        tNode.removeAttribute('id');
        var tBodyNode = document.createElement("TBODY");
        for (var x = 1; x < arr.length; x++)
        {
            var nextElement = document.getElementById(this.IDPrefix + arr[x]);
            nextElement = nextElement.cloneNode(true);
            nextElement.removeAttribute('id');
            tBodyNode.appendChild(nextElement);
        }
        tNode.appendChild(tBodyNode);
        var parentDiv = document.createElement("DIV");
        parentDiv.style.display = 'none';
        parentDiv.style.position = 'absolute';
        parentDiv.style.top = "0px";
        parentDiv.style.left = "0px";
        parentDiv.id = this.IDPrefix + id;
        parentDiv.appendChild(tNode);
        if (tNodeOrigWidth > 0)
        {
            // Set the new cloned fixed header node's style width to the width which
            // corresponds to the text-wrapping behavior for the column header before scrolling.        
            parentDiv.style.width = tNodeOrigWidth + "px";
            tNode.style.width = tNodeOrigWidth + "px";
        }
        var reportDiv = document.getElementById(this.ReportCellId);
        reportDiv.appendChild(parentDiv);
        return parentDiv;
    },
    ShowFixedTablixHeaders: function(m, fnh, rg, cg, ch, c1, c2, tr)
    {
        var om = document.getElementById(this.IDPrefix + m);
        var ofnh = document.getElementById(this.IDPrefix + fnh);
        var org = document.getElementById(this.IDPrefix + rg);
        var ocg = document.getElementById(this.IDPrefix + cg);
        var och = document.getElementById(this.IDPrefix + ch);
        var oc1 = document.getElementById(this.IDPrefix + c1);
        var oc2 = document.getElementById(this.IDPrefix + c2);
        var otr = document.getElementById(this.IDPrefix + tr);
        var rptDiv = document.getElementById(this.ReportDivId);
        var isIE8StandardsOrLater = Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater() && Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode();
        var isIEQuirksMode = Microsoft_ReportingServices_HTMLRenderer_IsIE() && !Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode();

        //Calculate the visual scroll offset
        var offsetParent = rptDiv;
        var scT = 0;
        var scL = 0;
        var dscT = 0;
        var clHeight = 0;
        var clWidth = 0;

        var parentWithAuto = rptDiv;
        while (parentWithAuto && parentWithAuto.style && 'auto' != parentWithAuto.style.overflow)
        {
            parentWithAuto = parentWithAuto.parentNode;
        }

        if (!parentWithAuto || !parentWithAuto.style)
        {
            scT = document.body.scrollTop;
            scL = document.body.scrollLeft;
            clHeight = document.body.clientHeight;
            clWidth = document.body.clientWidth;

            var htmlElement = document.body.parentNode;
            if (htmlElement && scL == 0 && scT == 0 && (htmlElement.scrollTop != 0 || htmlElement.scrollLeft != 0))
            {
                scT = htmlElement.scrollTop;
                scL = htmlElement.scrollLeft;
            }
        }
        else
        {
            offsetParent = parentWithAuto;
            scT = offsetParent.scrollTop;
            scL = offsetParent.scrollLeft;
            clHeight = offsetParent.clientHeight;
            clWidth = offsetParent.clientWidth;
        }

        //Calculate the offset of the item with the fixedheader relative to the scrollable area
        var offL = 0;
        var offT = 0;

        var o = om;
        while (o && o.id != rptDiv.id)
        {
            if (o.offsetLeft > 0) //Ignore RTL bits
                offL += o.offsetLeft;

            if (o.offsetTop > 0)
            {
                // IE8 standards mode - offsetTop can be negative when column fixedHeaders are moved vertically down.
                offT += o.offsetTop;
            }
            var oOffsetParent = o.offsetParent;
            //Walk the parents looking for either the ReportDivId or the offsetParent
            while (o != oOffsetParent && o.id != rptDiv.id)
            {
                o = o.parentNode;
            }
        }
        if (!o)
            o = document.getElementById(this.ContainerId);
        var rptCell = document.getElementById(this.ReportCellId);

        //Factor in Zoom
        var zt = rptCell.style.zoom;
        if (zt && zt.substring(zt.length - 1) == '%')
        {
            zm = zt.substring(0, zt.length - 1) / 100;
        }
        else
        {
            zm = zt;
        }

        if (!zm || zm == 0) zm = 1;

        var fixedHeaderScaleFactor = zm;

        if (!isIE8StandardsOrLater)
        {
            offL *= zm;
            offT *= zm;
            fixedHeaderScaleFactor = 1;
        }

        //Hide any of the FixedHeader regions that shouldn't be visible
        if (ocg != null) ocg.style.display = 'none';
        if (org != null) org.style.display = 'none';
        if (och != null) och.style.display = 'none';
        var zomoh = om.offsetHeight * zm;
        if (om.offsetHeight == 0)
            zomoh = document.body.offsetHeight * zm;

        var zomow = om.offsetWidth * zm;
        if (om.offsetWidth == 0)
            zomow = document.body.offsetWidth * zm;

        var zofnhot = Math.round(ofnh.offsetTop / fixedHeaderScaleFactor) * zm;

        var zocow = 0;
        if (oc1 && oc2)
        {
            zocow = ((Math.round(oc2.offsetLeft / fixedHeaderScaleFactor) + oc2.offsetWidth) - Math.round(oc1.offsetLeft / fixedHeaderScaleFactor)) * zm;
        }
        // clHeight, clWidth are not scaled in IE8 standards mode, even though offT,scT,offL,scL are.
        if ((scT >= (offT + zomoh - zofnhot)) || (scT + clHeight * fixedHeaderScaleFactor <= offT))
        {
            ocg = null;
        }
        if ((scL + clWidth * fixedHeaderScaleFactor - zocow <= offL) || (scL >= offL + zomow - zocow))
        {
            org = null;
        }

        //If none are visible, return
        if (!ocg && !org)
        {
            return;
        }

        //Update all the sizes
        if (org != null)
        {
            var rows = om.childNodes[0].childNodes;
            var fhrows = org.childNodes[0].childNodes[0].childNodes;
            var notIE7 = !Microsoft_ReportingServices_HTMLRenderer_IsIE() || Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater();

            var i, j;
            for (i = fhrows.length - 1, j = rows.length - 1; i > 0; i--, j--)
            {
                var rowHeight = rows[j].childNodes[0].offsetHeight;
                if (rows[j].getBoundingClientRect)
                {
                    var rowBoundingRect = rows[j].getBoundingClientRect();
                    var boundingHeight = rowBoundingRect.bottom - rowBoundingRect.top;

                    // Get the max rowspan of all <td> childNodes of this <tr> node.
                    var maxTDRowSpan = Microsoft_ReportingServices_HTMLRenderer_GetMaxChildRowSpan(rows[j]);
                    if (maxTDRowSpan > 1)
                    {
                        if (j + 1 < rows.length)
                        {
                            var nextRowBoundingRect = rows[j + 1].getBoundingClientRect();
                            // Use the bottom row's top and subtract it from this row's top
                            // to get the appropriate height of this row.
                            boundingHeight = nextRowBoundingRect.top - rowBoundingRect.top;
                        }
                    }

                    // The bouding rectangle increases proportionally to zoom.
                    boundingHeight = boundingHeight / zm;

                    if (boundingHeight > rowHeight)
                        rowHeight = boundingHeight;
                }

                if (notIE7 && !rows[j].getAttribute("height")) //Do not write in IE6 or 7
                {
                    rows[j].setAttribute("height", rowHeight);
                }

                fhrows[i].childNodes[0].style.height = rowHeight + "px";
            }
        }
        if (och != null)
        {
            var rows = om.childNodes[0].childNodes;
            var fhrows = och.childNodes[0].childNodes[0].childNodes;
            for (i = 0; i < fhrows.length; i++) fhrows[i].childNodes[0].style.height = rows[i].childNodes[0].offsetHeight + "px";
        }
        if (ocg != null)
        {
            var cols = om.childNodes[0].childNodes[0];
            var omFirstChildWidth = om.childNodes[0].clientWidth;
            // In IE quirks mode, when creating the column fixed header,
            // the style width is explicitly set on that fixed header. Don't
            // overwrite the style width if the overwriting value is 0.
            if (omFirstChildWidth > 0 || !isIEQuirksMode)
            {
                ocg.childNodes[0].style.width = omFirstChildWidth + "px";
            }
            for (i = 0; i < cols.childNodes.length; i++)
            {
                var colsChildWidth = cols.childNodes[i].offsetWidth;
                if (colsChildWidth > 0 || !isIEQuirksMode)
                {
                    var ocgFHChildNode = ocg.childNodes[0].childNodes[0].childNodes[0].childNodes[i];
                    if (ocgFHChildNode != null)
                    {
                        ocgFHChildNode.style.width = colsChildWidth + "px";
                        if (isIE8StandardsOrLater)
                        {
                            ocgFHChildNode.style.minWidth = colsChildWidth + "px";
                        }
                    }
                }
            }
        }

        //Position the FixedHeaders
        if (ocg != null)
        {
            ocg.style.zoom = zt;
            ocg.style.left = Math.round(offL / fixedHeaderScaleFactor) + "px";
            var zdbch = document.body.clientHeight;

            if (!((offT > scT) && ((scT + zdbch) > offT)))
            {
                ocg.style.display = '';
                var topOffset = scT;
                ocg.style.top = Math.round(topOffset / fixedHeaderScaleFactor) + "px";
            }
        }
        var zocol = 0;
        if (oc1)
        {
            zocol = oc1.offsetLeft * zm;
        }
        if (org != null)
        {
            org.style.zoom = zt;
            zoccw = ((Math.round(oc2.offsetLeft / fixedHeaderScaleFactor) + oc2.offsetWidth) * zm) - Math.max(scL, Math.round(oc1.offsetLeft / fixedHeaderScaleFactor) * zm);
            zoccw = Math.max(0, zoccw);
            var zomol = Math.round(om.offsetLeft / fixedHeaderScaleFactor) * zm;
            if ((scL > (zocol + offL)) && (scL < offL + zomow - zocow))
            {
                org.style.display = '';
                var topOffset = offT - dscT;
                var leftOffset = scL;
                org.style.top = Math.round(topOffset / fixedHeaderScaleFactor) + "px";
                org.style.left = Math.round(leftOffset / fixedHeaderScaleFactor) + "px";
                org.style.width = zoccw + "px";
            }
            else if (((scL + clWidth) < (zocol + zocow + offL)) && (scL + clWidth - zoccw > offL + zomol))
            {
                org.style.display = '';
                org.style.top = Math.round((offT - dscT) / fixedHeaderScaleFactor) + "px";
                org.style.left = Math.round((scL + clWidth - zoccw) / fixedHeaderScaleFactor) + "px";
                org.style.width = zoccw + "px";
            }
        }
        if (och != null && org && ocg && org.style.display == '' && ocg.style.display == '')
        {
            och.style.zoom = zt;
            och.style.display = '';
            och.style.top = ocg.style.top;
            och.style.left = org.style.left;
            och.style.width = org.style.width;
        }
    }
}
// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
function Microsoft_ReportingServices_HTMLRenderer_GrowTablixTextBoxes(topElementId)
{
    var topElement = document;
    if (topElementId)
    {
        topElement = document.getElementById(topElementId);
        if(!topElement)
          topElement = document;
    }
    var tags = topElement.getElementsByTagName("div");
    for (var i = 0; i < tags.length; i++)
    {
        if (tags[i].getAttribute("nogrow"))
        {
            var tag = tags[i];
            var parent = tag.parentNode;
            var targetHeight = parent.offsetHeight;
            if (tag.offsetHeight != targetHeight)
            {
                //Update Height
                var divTargetHeight = targetHeight;
                if (tag.scrollHeight < targetHeight)
                {
                    divTargetHeight = tag.scrollHeight;
                }

                tag.style.height = divTargetHeight + "px";
                //Borders or paddings can affect the sizing.  Make sure the child doesn't alter the size of the parent.
                diff = parent.offsetHeight - targetHeight;
                if (diff > 0)
                    tag.style.height = (divTargetHeight - diff) + "px";

                //Which one first?  Width or height?
                var targetWidth = parent.offsetWidth;
                var divTargetWidth = targetWidth;
                var useScrollWidth = false;
                if (tag.scrollWidth > targetWidth)
                {
                    divTargetWidth = tag.scrollWidth;
                    useScrollWidth = true;
                }
                    
                tag.style.width = divTargetWidth + "px";
                //Borders or paddings can affect the sizing.  Make sure the child doesn't alter the size of the parent.
                var diff = parent.offsetWidth - targetWidth;
                if (diff > 0 && !useScrollWidth)
                {
                    //Allow the width to grow if the scrollwidth is wider than the current width.  Particularly important for Sorts.
                    tag.style.width = (targetWidth - diff) + "px";
                }
            }
            //Do this calculation once
            tag.removeAttribute("nogrow");
        }
    }
}// <copyright company="Microsoft">
//     Copyright (c) Microsoft.  All rights reserved.
// </copyright>
function Microsoft_ReportingServices_HTMLRenderer_ScaleImageConsolidation(prefixId, topElementId, reportCellId)
{
    var topElement = document;
    if (topElementId)
    {
        topElement = document.getElementById(topElementId);
        if (!topElement)
            topElement = document;
    }

    var stdMode = Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode();
    var isIE = Microsoft_ReportingServices_HTMLRenderer_IsIE();
    var isIE7OrLess = !Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater();

    var imgConImageIdsTagId = "imgConImageIdsTag";
    if (prefixId)
    {
        imgConImageIdsTagId = prefixId + imgConImageIdsTagId;
    }

    var imgConImageIdsTag = document.getElementById(imgConImageIdsTagId);
    if (imgConImageIdsTag)
    {
        var idsString = imgConImageIdsTag.getAttribute("ids");
        if (idsString)
        {
            var ids = idsString.split(",");
            for (var i = 0; i < ids.length; i++)
            {
                var id = ids[i];
                if ((id) && (id != ""))
                {
                    var div = document.getElementById(id);
                    if (div)
                    {
                        //All Consolidated Images requiring scaling will have the "imgConImage" attribute
                        var imgType = div.getAttribute("imgConImage");
                        if (!imgType)
                        {
                            continue;
                        }

                        var divWidth = 0;
                        var divHeight = 0;

                        var needsSize = imgType == "Fit" || imgType == "Clip";
                        if (needsSize)
                        {
                            divWidth = div.parentNode.clientWidth;
                            divHeight = div.parentNode.clientHeight;

                            if (stdMode)
                            {
                                if (divWidth == 0 && div.getAttribute("origWidth"))
                                {
                                    divWidth = div.getAttribute("origWidth");
                                }
                                else
                                {
                                    divWidth = divWidth + "px";
                                }

                                if (divHeight == 0 && div.getAttribute("origHeight"))
                                {
                                    divHeight = div.getAttribute("origHeight");
                                }
                                else
                                {
                                    divHeight = divHeight + "px";
                                }
                            }
                        }

                        //If standards mode, set position:relative on the outer div.
                        if (isIE)
                        {
                            if (stdMode)
                            {
                                div.style.position = "relative";
                                if (isIE7OrLess && needsSize)
                                {
                                    var offsets = Microsoft_ReportingServices_HTMLRenderer_CalculateOffset(topElement, div.parentNode);
                                    div.setAttribute("origLeft", offsets.left);
                                    div.setAttribute("origTop", offsets.top);
                                }
                            }
                            //No relative for quirks mode
                        }
                        else
                        {
                            div.style.position = "relative";
                        }

                        if (imgType == "Fit")
                        {
                            var height = parseFloat(divHeight);
                            var width = parseFloat(divWidth);

                            height = Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalPaddings(div.parentNode, height);
                            if (height < 0)
                            {
                                height = 1;
                            }
                            width = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalPaddings(div.parentNode, width);
                            if (width < 0)
                            {
                                width = 1;
                            }


                            var imgsInDiv = div.getElementsByTagName("IMG");
                            if (imgsInDiv.length == 0)
                                continue;
                            var img = imgsInDiv[0];

                            // div for image started out as 1px by 1px (to prevent effects of growth due to large paddings.
                            // Set the div height and width back to original imageConsolidation sizes (from attributes "imgConWidth" and
                            // "imgConHeight").
                            div.style.width = div.getAttribute("imgConWidth") + "px";
                            div.style.height = div.getAttribute("imgConHeight") + "px";
                            div.removeAttribute("imgConWidth");
                            div.removeAttribute("imgConHeight");

                            //Calculate the scaling factor
                            var xScale = width / parseInt(div.style.width);
                            var yScale = height / parseInt(div.style.height);
                            var endWidth = xScale * parseInt(img.width);
                            var endHeight = yScale * parseInt(img.height);
                            //Scale the Consolidated Image
                            img.width = endWidth;
                            img.height = endHeight;
                            div.style.width = width + "px";
                            div.style.height = height + "px";

                            //Scale the Offsets within the Image
                            var topOffset = (parseInt(img.style.top) * yScale);
                            var leftOffset = (parseInt(img.style.left) * xScale);
                            img.style.top = topOffset + "px";
                            img.style.left = leftOffset + "px";

                            // ImageMap scaling
                            var maps = div.getElementsByTagName("MAP");
                            if (maps.length == 0)
                                continue;
                            Microsoft_ReportingServices_HTMLRenderer_UpdateMap(maps[0], yScale);
                        }
                        else if (imgType == "Clip")
                        {
                            div.style.height = divHeight;
                            div.style.width = divWidth;
                        }
                    }
                }
            }
        }
    }
}

function Microsoft_ReportingServices_HTMLRenderer_UpdateMap(map, yScale)
{
    if (map.areas)
    {
        for (var i = 0; i < map.areas.length; i++)
            Microsoft_ReportingServices_HTMLRenderer_UpdateArea(map.areas[i], yScale);
    } 
}

function Microsoft_ReportingServices_HTMLRenderer_UpdateArea(area, yScale)
{
    if (area.coords)
    {
        var coords = area.coords.split(',');
        var index = 0;
        var outputCoords = "";
        var firstPair = true;
        // Coordinates come in pairs except for the circle radius.
        while (index < coords.length - 1)
        {
            if (!firstPair)
            {
                outputCoords += ",";
            }

            outputCoords += coords[index];
            outputCoords += ",";
            outputCoords += parseInt(coords[index + 1]) * yScale;
            firstPair = false;
            index += 2;
        }

        // Circle Radius.  Not uniformly scaled, so not scaled at all.
        if (index < coords.length)
        {
            outputCoords += ",";
            outputCoords += coords[index];
        }

        area.coords = outputCoords;
    }
}

function Microsoft_ReportingServices_HTMLRenderer_ScaleImageUpdateZoom(prefixId, topElementId, reportCellId)
{
    //Only for IE6/7 in standards mode
    if (Microsoft_ReportingServices_HTMLRenderer_IsStandardsMode())
    {
        if (!Microsoft_ReportingServices_HTMLRenderer_IsIE()
      || Microsoft_ReportingServices_HTMLRenderer_IsIE8OrLater())
            return;
    }
    else
    {
        return;
    }

    var zoom = Microsoft_ReportingServices_HTMLRenderer_CalculateZoom(reportCellId);
    var topElement = document;
    if (topElementId)
    {
        topElement = document.getElementById(topElementId);
        if (!topElement)
            topElement = document;
    }
    var reportDiv = topElement;

    var imgConImageIdsTagId = "imgConImageIdsTag";
    if (prefixId)
    {
        imgConImageIdsTagId = prefixId + imgConImageIdsTagId;
    }

    var imgConImageIdsTag = document.getElementById(imgConImageIdsTagId);
    if (imgConImageIdsTag)
    {
        var idsString = imgConImageIdsTag.getAttribute("ids");
        if (idsString)
        {
            var ids = idsString.split(",");
            for (var i = 0; i < ids.length; i++)
            {
                var id = ids[i];
                if ((id) && (id != ""))
                {
                    var div = document.getElementById(id);
                    if (div)
                    {
                        var imgType = div.getAttribute("imgConImage");
                        if (imgType == "Fit" || imgType == "AutoSize" || imgType == "Clip")
                        {
                            if (zoom != 1)
                            {
                                if (div.style.position == "relative")
                                {
                                    div.style.position = "absolute";
                                }

                                var offsets = Microsoft_ReportingServices_HTMLRenderer_CalculateOffset(reportDiv, div.parentNode);

                                div.style.left = (offsets.left * zoom) + "px";
                                div.style.top = (offsets.top * zoom) + "px";
                                div.style.zoom = zoom;
                            }
                            else
                            {
                                if (div.style.position == "absolute")
                                {
                                    div.style.position = "relative";
                                }

                                div.style.left = "auto";
                                div.style.top = "auto";
                                div.style.zoom = "normal";
                            }
                        }
                    }
                }
            }
        }
    }
}

function CalculateDocumentOffset(element)
{
    /// <summary>
    /// Returns the offset in pixesl of the given element from the body
    /// </summary>
    if (!element || !element.ownerDocument)
    {
        throw Error.argumentNull("element");
    }

    var box = element.getBoundingClientRect();
    var doc = element.ownerDocument;
    var body = doc.body;
    var docElem = doc.documentElement;

    // docElem.clientTop = non IE, body.clientTop = IE
    var clientTop = docElem.clientTop || body.clientTop || 0;
    var clientLeft = docElem.clientLeft || body.clientLeft || 0;

    // pageX/YOffset = FF, Safari docElem.scrollTop/Left = IE standards body.scrollTop/Left = IE quirks
    var top = box.top + (self.pageYOffset || docElem.scrollTop || body.scrollTop || 0) - clientTop;
    var left = box.left + (self.pageXOffset || docElem.scrollLeft || body.scrollLeft || 0) - clientLeft;

    return { top: top, left: left };
}

function Microsoft_ReportingServices_HTMLRenderer_ScaleImageForFit(prefixId, topElementId)
{
    var topElement = document;
    if (topElementId)
    {
        topElement = document.getElementById(topElementId);
        if (!topElement)
            topElement = document;
    }

    var imgFitDivIdTagsId = "imgFitDivIdsTag";
    if (prefixId)
    {
        imgFitDivIdTagsId = prefixId + imgFitDivIdTagsId;
    }

    // Need to separate loops for setting width and height (which were consolidated before).
    // IE7 standards mode sometimes does not respect first <td> element's height on a <tr> element,
    // until javascript execution causes re-rendering of page. Executing the width loop first
    // will trigger re-rendering of page, after which the loop to set the heights will have the correct
    // heights from the images.
    var imgFitDivIdsTag = document.getElementById(imgFitDivIdTagsId);
    if (imgFitDivIdsTag)
    {
        var idsString = imgFitDivIdsTag.getAttribute("ids");
        if (idsString)
        {
            var ids = idsString.split(",");
            for (var i = 0; i < ids.length; i++)
            {
                var id = ids[i];
                if ((id) && (id != ""))
                {
                    var div = document.getElementById(id);
                    if (div)
                    {
                        var imgsInDiv = div.getElementsByTagName("IMG");
                        if (imgsInDiv.length == 0)
                            continue;
                        var img = imgsInDiv[0];


                        var width = div.parentNode.clientWidth;
                        width = Microsoft_ReportingServices_HTMLRenderer_SubtractHorizontalPaddings(div.parentNode, width);
                        if (width < 0)
                        {
                            width = 1;
                        }

                        img.width = width;
                        if (img.width != width)
                        {
                            img.style.width = width + "px";
                        }
                    }
                }
            }

            for (var i = 0; i < ids.length; i++)
            {
                var id = ids[i];
                if ((id) && (id != ""))
                {
                    var div = document.getElementById(id);
                    if (div)
                    {
                        var imgsInDiv = div.getElementsByTagName("IMG");
                        if (imgsInDiv.length == 0)
                            continue;
                        var img = imgsInDiv[0];

                        var height = div.parentNode.clientHeight;

                        height = Microsoft_ReportingServices_HTMLRenderer_SubtractVerticalPaddings(div.parentNode, height);
                        if (height < 0)
                        {
                            height = 1;
                        }

                        img.height = height;

                        if (img.height != height)
                        {
                            img.style.height = height + "px";
                        }
                    }
                }
            }
        }
    }
}

if (typeof(Sys) !== 'undefined') Sys.Application.notifyScriptLoaded();