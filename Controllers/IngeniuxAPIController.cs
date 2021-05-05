using Ingeniux.Runtime.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;

namespace Ingeniux.Runtime.Controllers
{
	[RoutePrefix("api")]
    [ApiExplorerSettings(IgnoreApi = false)]
    public class IngeniuxAPIController : ApiController
    {
        public IngeniuxAPIController():base()
        {
            HttpContext.Current.Response.Headers.Add("MaxRecords", "1000");
        }

        [IGXWebApiCache()]
        [Route("content/{pageURL?}")]
        [ResponseType(typeof(PageModel))]
        public PageModel GetPage(string pageUrl="/")
        {
            //System.Diagnostics.Debugger.Launch();
            if (!pageUrl.StartsWith("/") && !pageUrl.IsXId())
            {
                pageUrl = $"/{pageUrl}";
            }
            string sitePath = CmsRoute.GetSitePath();
            var context = new HttpContextWrapper(HttpContext.Current);
            HttpRequestBase _request = context.Request;
            CMSPageFactory pageFactory = new CMSPageFactory(sitePath);
            ICMSPage page;
            if (!pageUrl.IsXId())
            {
                page = pageFactory.GetPageByPath(_request, pageUrl) as ICMSPage;
                
            }
            else
            {
                page = pageFactory.GetPage(_request, pageUrl) as ICMSPage;
            }

            if(page == null)
            {
                throw new HttpResponseException(Request.CreateErrorResponse(HttpStatusCode.NotFound,"this item does not exist"));
            }

            Request.Properties[IGXWebApiCacheAttribute.NAVS_CACHED_PROP_NAME] = (page as CMSPageRequest).NavigationUsingCacheContent;

            var eleExceptions = new ElementModel().ElementExceptionList;
            var attrExceptions = new ElementModel().AttributeExceptionList;

            var pageModel =  new PageModel()
            {
                Attributes = page
                    .Attributes()
                    .Where(pageAttrs => !attrExceptions.Contains(pageAttrs.AttributeName))
                    .ToDictionary(pageAttrs => pageAttrs.AttributeName, pageAttrs => pageAttrs.Value),
                Elements = page
                    .Elements()
                    .Select(e => new ElementModel(e)).Where(e => !eleExceptions.Contains(e.Name))
            };

            // check for page Element 'Content'
            if (pageModel.Elements.Where(elt => elt.Name == "Content").Any())
            {
                // convert with XSLT Stylesheet and add to dictionary
                //var contentEle = pageModel.Elements.Where(elt => elt.Name == "Content").Single();
                //var ditaContent = contentEle != null ? contentEle.Value : "";                
                var transformedString = DitaHelper.GetTransformedXML(page);

                // expand internal tabs/accordions
                if (!string.IsNullOrWhiteSpace(transformedString))
                {
                    transformedString = DitaHelper.ExpandInternalTabs(transformedString, pageFactory, _request);
                }

                if (!string.IsNullOrWhiteSpace(transformedString))
                {
                    var pageElements = pageModel.Elements.ToList();

                    var contentEle = new ElementModel(page.Element("Content"));
                    contentEle.Value = transformedString;
                    contentEle.Children = Enumerable.Empty<ElementModel>();
                    // get index of current Content ele
                    pageElements[pageElements.FindIndex(elt => elt.Name == "Content")] = contentEle;

                    pageModel.Elements = pageElements;
                }
            }

            pageModel.Attributes.Add("TestTime", System.DateTime.Now.ToString());

            return pageModel;

        }


    }
}
