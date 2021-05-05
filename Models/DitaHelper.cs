using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Hosting;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace Ingeniux.Runtime.Models
{
	public class DitaHelper
	{

        public static string GetTransformedXML(ICMSPage page)
        {
            ICMSElement ditaXML = page.Element("Content", "");

            String xsltFilePath = HostingEnvironment.MapPath("~/Content/ditastylesheets/ditaRender-cxp.xsl");
            String stylesheetFolderPath = HostingEnvironment.MapPath("~/Content/ditastylesheets/");
            ICMSElement ditaContentNode = ditaXML.Elements().FirstOrDefault(c => c.RootElementName != "IGX_XELE_DocType");

            String insertContent = ditaContentNode != null ? ditaContentNode.Content.ToString() : ditaXML != null && !string.IsNullOrWhiteSpace(ditaXML.Value) ? ditaXML.Value : "";
            String transformedContent = insertContent;

            //String mapViewMode = !String.IsNullOrWhiteSpace(ViewBag.LeftNavMap) ? ViewBag.LeftNavMap : "";
            String mapViewMode = "tocwithdesc";

            if (File.Exists(xsltFilePath) && !string.IsNullOrWhiteSpace(insertContent) && insertContent != "Xml Element Error: Invalid xml: Root element is missing.")
            {
                string readText = File.ReadAllText(xsltFilePath);
                transformedContent = TransformXMLToHTML(insertContent, readText, mapViewMode, "", "", stylesheetFolderPath, page);
            }

            return transformedContent;
        }

        public static string TransformXMLToHTML(string inputXml, string xsltString, string mapViewMode, string thisPageUrl, string rootMapPageId, string stylesheetFolderPath, ICMSPage page)
        {
            //string _byteOrderMarkUtf8 = Encoding.UTF8.GetString(Encoding.UTF8.GetPreamble());
            //if (inputXml.StartsWith(_byteOrderMarkUtf8))
            //{
            //    inputXml = xsltString.Remove(0, _byteOrderMarkUtf8.Length);
            //}

            inputXml = ReplaceImageAssetPaths(inputXml, page);

            XmlReaderSettings settings = new XmlReaderSettings();
            settings.DtdProcessing = DtdProcessing.Ignore;
            //settings.MaxCharactersFromEntities = 1024;

            XsltArgumentList argsList = new XsltArgumentList();
            argsList.AddParam("StylesheetsFolderPath", "", stylesheetFolderPath);
            argsList.AddParam("ViewMode", "", mapViewMode);

            argsList.AddParam("ThisPageUrl", "", thisPageUrl);
            argsList.AddParam("RootMapPageId", "", rootMapPageId);

            XslCompiledTransform transform = new XslCompiledTransform();
            XmlUrlResolver resolver = new XmlUrlResolver();
            resolver.Credentials = CredentialCache.DefaultNetworkCredentials;
            using (XmlReader reader = XmlReader.Create(new StringReader(xsltString), settings, stylesheetFolderPath))
            {

                transform.Load(reader, null, resolver);

            }
            StringWriter results = new StringWriter();
            using (XmlReader reader = XmlReader.Create(new StringReader(inputXml), settings, stylesheetFolderPath))
            {
                transform.Transform(reader, argsList, results);
            }


            return results.ToString();
        }

        public static string ReplaceImageAssetPaths(string inputXml, ICMSPage page)
        {
            string replacedString = inputXml;
            // get all hrefs that start with a/ asset ID
            XDocument ditaDoc = XDocument.Parse(inputXml);

            //process map refs
            var allHrefs = ditaDoc.XPathSelectElements("//*[@href]");
            var assetHrefs = allHrefs != null && allHrefs.Any() ? allHrefs.Where(elt => elt.GetAttributeValue("href", "").ToString().StartsWith("a/")) : new XElement[0];
            var pageHrefs = allHrefs != null && allHrefs.Any() ? allHrefs.Where(elt => elt.GetAttributeValue("href", "").ToString().StartsWith("x")) : new XElement[0];

            if (assetHrefs != null && assetHrefs.Any())
            {
                foreach (var assetHref in assetHrefs)
                {
                    var assetId = assetHref.GetAttributeValue("href", "");

                    var asset = page.Factory.AssetMap.GetAssetByID(assetId);

                    if (asset != null)
                    {
                        //assetPathsById.Add(asset.AssetId, asset.Url);
                        assetHref.SetAttributeValue("href", asset.Url);
                    }
                }
            }

            // can't get an SURL value for preview links
            if (pageHrefs != null && pageHrefs.Any())
            {
                foreach (var pageHref in pageHrefs)
                {
                    var href = pageHref.GetAttributeValue("href", "");
                    string pageId = href;
                    string bookmark = "";
                    bool hasBookmark = pageId.Contains("#");

                    if (hasBookmark)
                    {
                        pageId = href.SubstringBefore("#");
                        bookmark = href.SubstringAfter("#", true, true);
                    }

                    var urlMap = page.Factory != null && page.Factory.UrlMap != null ? page.Factory.UrlMap : null;
                    var pageData = urlMap != null ? urlMap.GetPageDataByID(pageId) : null;

                    if (pageData != null)
                    {
                        var pageLink = pageData.CanonicalUrl;

                        if (hasBookmark)
                        {
                            pageLink = pageLink + "#" + bookmark;
                        }

                        if (!string.IsNullOrWhiteSpace(pageLink))
                        {
                            // trim leading slash?
                            if (pageLink.StartsWith("/"))
                            {
                                pageLink = pageLink.TrimStart('/');
                            }
                            pageHref.SetAttributeValue("href", pageLink);
                        }
                    }


                }
            }

            replacedString = ditaDoc.ToString();

            // lookup asset ids in AssetFactory for path


            // replace href asset Ids with path

            return replacedString;
        }
    }
}