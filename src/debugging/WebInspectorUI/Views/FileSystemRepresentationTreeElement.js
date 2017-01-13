WebInspector.FileSystemRepresentationTreeElement = class FileSystemRepresentationTreeElement extends WebInspector.FolderTreeElement
{
    constructor(mainFrame)
    {
        super("app", "", [], mainFrame);

        this.resources = mainFrame.resources;
        this.foldersByPath = new Map;
        this.foldersByPath.set("/app", this);

        this.expanded = true;
    }

    onpopulate() 
    {
        if (this.foldersByPath.get("/app").children.length)
            return;

        for(var resource of this.resources) 
        {
            var path = resource.urlComponents.path;
            var pathComponents = path.replace(/^\//g, "").split('/');
            var fileName = pathComponents[pathComponents.length - 1];
            var directoryPath = path.substring(0, path.lastIndexOf('/'));
            var parentFolderElement;
            var resourceElement = new WebInspector.ResourceTreeElement(resource, null);

            if(this.foldersByPath.has(directoryPath)) {
                parentFolderElement = this.foldersByPath.get(directoryPath);
            } else {
                parentFolderElement = this._generateParentFolderElement(pathComponents.slice(0, pathComponents.length - 1));
            }

            parentFolderElement.insertChild(resourceElement, insertionIndexForObjectInListSortedByFunction(resourceElement, parentFolderElement.children, this.compareChildTreeElements.bind(this)));
        }
    }

    removeFile(fileURLString) {
        let path = parseURL(fileURLString).path;
        let directoryPath = path.substring(0, path.lastIndexOf('/'));

        if (this.foldersByPath.has(directoryPath)) {
            let parentFolderElement = this.foldersByPath.get(directoryPath);

            for (let child of parentFolderElement.children) {
                if (child.representedObject.url === fileURLString) {
                    parentFolderElement.removeChild(child, true, true);
                    break;
                }
            }
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
        for(var pathComponent of pathComponents) {
            nextPath = currentPath + '/' + pathComponent;
             if(!this.foldersByPath.has(nextPath)) {
                parentFolderElement = new WebInspector.FolderTreeElement(pathComponent, "", [], null);

                var parentFolder = this.foldersByPath.get(currentPath);
                parentFolder.insertChild(parentFolderElement, insertionIndexForObjectInListSortedByFunction(parentFolderElement, parentFolder.children, this.compareChildTreeElements.bind(this)));      
                this.foldersByPath.set(nextPath, parentFolderElement);
             }
             currentPath = nextPath;
        }

        return parentFolderElement;
    }
};