WebInspector.FileSystemResourcesHelper = class FileSystemResourcesHelper extends WebInspector.FolderTreeElement
{
    constructor(mainFrame)
    {
        super("app", "", [], mainFrame);

        this.resources = mainFrame.resources;
        this.foldersByPath = new Map;
        this.foldersByPath.set("/app", this);

        this.expanded = true;
    }

    populate() 
    {
        for(var i = 0; i < this.resources.length; ++i) 
        {
            var path = this.resources[i].urlComponents.path;
            var pathComponents = path.replace(/^\//g, "").split('/');
            var fileName = pathComponents[pathComponents.length - 1];
            var directoryPath = path.substring(0, path.lastIndexOf('/'));
            var parentFolderElement;
            var resourceElement = new WebInspector.ResourceTreeElement(this.resources[i], null);            

            if(this.foldersByPath.has(directoryPath)) {
                parentFolderElement = this.foldersByPath.get(directoryPath);                
            } else {
                parentFolderElement = this._generateParentFolderElement(pathComponents.slice(0, pathComponents.length - 1));
            }

            parentFolderElement.insertChild(resourceElement, insertionIndexForObjectInListSortedByFunction(resourceElement, parentFolderElement.children, this.compareChildTreeElements.bind(this)));
        }
    }

    _compareTreeElementsByMainTitle(a, b)
    {
        return a.mainTitle.localeCompare(b.mainTitle);
    }

    compareChildTreeElements(a, b)
    {
        return this._compareTreeElementsByMainTitle(a, b);
    }

    _generateParentFolderElement(pathComponents) 
    {
        var currentPath = "";
        var nextPath = "";
        var parentFolderElement;
        for(var i = 0; i < pathComponents.length; i++) {           
            nextPath = currentPath + '/' + pathComponents[i];
             if(!this.foldersByPath.has(nextPath)) {                
                parentFolderElement = new WebInspector.FolderTreeElement(pathComponents[i], "", [], null);

                var parentFolder = this.foldersByPath.get(currentPath);     
                parentFolder.insertChild(parentFolderElement, insertionIndexForObjectInListSortedByFunction(parentFolderElement, parentFolder.children, this.compareChildTreeElements.bind(this)));      
                this.foldersByPath.set(nextPath, parentFolderElement);
             }
             currentPath = nextPath;
        }

        return parentFolderElement;
    }
};