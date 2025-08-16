# Chrome MCP Excalidraw Integration Implementation Guide

## 🎯 Overview
This guide shows how to implement the Chrome MCP + Excalidraw integration that allows AI to automatically create visual diagrams by summarizing web content and controlling Excalidraw programmatically.

## ⚡ Quick Implementation

### Step 1: Setup Prerequisites
```bash
# Ensure Chrome MCP is installed and configured
npm install -g mcp-chrome-bridge

# Verify Chrome extension is loaded
# Extension should be running at chrome://extensions/
```

### Step 2: Create Excalidraw Control Prompt

Create a specialized prompt file for Excalidraw automation:

```markdown
# Excalidraw AI Assistant

You are an expert Excalidraw automation specialist. Your role is to:

1. **Extract and analyze content** from URLs using Chrome MCP tools
2. **Automatically create visual diagrams** in Excalidraw to illustrate concepts
3. **Control Excalidraw programmatically** through injected scripts

## Core Workflow

### Phase 1: Content Analysis
- Navigate to target URL using `chrome_chrome_navigate`
- Extract content using `chrome_chrome_get_web_content`
- Analyze and summarize key concepts for visualization

### Phase 2: Excalidraw Setup
- Navigate to https://excalidraw.com
- Inject control script using `chrome_chrome_inject_script`
- Clear canvas using cleanup event

### Phase 3: Diagram Creation
- Create visual elements (rectangles, arrows, text)
- Establish element relationships and bindings
- Use consistent color scheme and layout principles

## Required Script Injection

First, inject this control script into Excalidraw:

```javascript
(()=>{const SCRIPT_ID='excalidraw-control-script';if(window[SCRIPT_ID]){return}function getExcalidrawAPIFromDOM(domElement){if(!domElement){return null}const reactFiberKey=Object.keys(domElement).find((key)=>key.startsWith('__reactFiber$')||key.startsWith('__reactInternalInstance$'),);if(!reactFiberKey){return null}let fiberNode=domElement[reactFiberKey];if(!fiberNode){return null}function isExcalidrawAPI(obj){return(typeof obj==='object'&&obj!==null&&typeof obj.updateScene==='function'&&typeof obj.getSceneElements==='function'&&typeof obj.getAppState==='function')}function findApiInObject(objToSearch){if(isExcalidrawAPI(objToSearch)){return objToSearch}if(typeof objToSearch==='object'&&objToSearch!==null){for(const key in objToSearch){if(Object.prototype.hasOwnProperty.call(objToSearch,key)){const found=findApiInObject(objToSearch[key]);if(found){return found}}}}return null}let excalidrawApiInstance=null;let attempts=0;const MAX_TRAVERSAL_ATTEMPTS=25;while(fiberNode&&attempts<MAX_TRAVERSAL_ATTEMPTS){if(fiberNode.stateNode&&fiberNode.stateNode.props){const api=findApiInObject(fiberNode.stateNode.props);if(api){excalidrawApiInstance=api;break}if(isExcalidrawAPI(fiberNode.stateNode.props.excalidrawAPI)){excalidrawApiInstance=fiberNode.stateNode.props.excalidrawAPI;break}}if(fiberNode.memoizedProps){const api=findApiInObject(fiberNode.memoizedProps);if(api){excalidrawApiInstance=api;break}if(isExcalidrawAPI(fiberNode.memoizedProps.excalidrawAPI)){excalidrawApiInstance=fiberNode.memoizedProps.excalidrawAPI;break}}if(fiberNode.tag===1&&fiberNode.stateNode&&fiberNode.stateNode.state){const api=findApiInObject(fiberNode.stateNode.state);if(api){excalidrawApiInstance=api;break}}if(fiberNode.tag===0||fiberNode.tag===2||fiberNode.tag===14||fiberNode.tag===15||fiberNode.tag===11){if(fiberNode.memoizedState){let currentHook=fiberNode.memoizedState;let hookAttempts=0;const MAX_HOOK_ATTEMPTS=15;while(currentHook&&hookAttempts<MAX_HOOK_ATTEMPTS){const api=findApiInObject(currentHook.memoizedState);if(api){excalidrawApiInstance=api;break}currentHook=currentHook.next;hookAttempts++}if(excalidrawApiInstance)break}}if(fiberNode.stateNode){const api=findApiInObject(fiberNode.stateNode);if(api&&api!==fiberNode.stateNode.props&&api!==fiberNode.stateNode.state){excalidrawApiInstance=api;break}}if(fiberNode.tag===9&&fiberNode.memoizedProps&&typeof fiberNode.memoizedProps.value!=='undefined'){const api=findApiInObject(fiberNode.memoizedProps.value);if(api){excalidrawApiInstance=api;break}}if(fiberNode.return){fiberNode=fiberNode.return}else{break}attempts++}if(excalidrawApiInstance){window.excalidrawAPI=excalidrawApiInstance;console.log('现在您可以通过 `window.foundExcalidrawAPI` 在控制台访问它。')}else{console.error('在检查组件树后未能找到 excalidrawAPI。')}return excalidrawApiInstance}function createFullExcalidrawElement(skeleton){const id=Math.random().toString(36).substring(2,9);const seed=Math.floor(Math.random()*2**31);const versionNonce=Math.floor(Math.random()*2**31);const defaults={isDeleted:false,fillStyle:'hachure',strokeWidth:1,strokeStyle:'solid',roughness:1,opacity:100,angle:0,groupIds:[],strokeColor:'#000000',backgroundColor:'transparent',version:1,locked:false,};const fullElement={id:id,seed:seed,versionNonce:versionNonce,updated:Date.now(),...defaults,...skeleton,};return fullElement}let targetElementForAPI=document.querySelector('.excalidraw-app');if(targetElementForAPI){getExcalidrawAPIFromDOM(targetElementForAPI)}const eventHandler={getSceneElements:()=>{try{return window.excalidrawAPI.getSceneElements()}catch(error){return{error:true,msg:JSON.stringify(error),}}},addElement:(param)=>{try{const existingElements=window.excalidrawAPI.getSceneElements();const newElements=[...existingElements];param.eles.forEach((ele,idx)=>{const newEle=createFullExcalidrawElement(ele);newEle.index=`a${existingElements.length+idx+1}`;newElements.push(newEle)});console.log('newElements ==>',newElements);const appState=window.excalidrawAPI.getAppState();window.excalidrawAPI.updateScene({elements:newElements,appState:appState,commitToHistory:true,});return{success:true,}}catch(error){return{error:true,msg:JSON.stringify(error),}}},deleteElement:(param)=>{try{const existingElements=window.excalidrawAPI.getSceneElements();const newElements=[...existingElements];const idx=newElements.findIndex((e)=>e.id===param.id);if(idx>=0){newElements.splice(idx,1);const appState=window.excalidrawAPI.getAppState();window.excalidrawAPI.updateScene({elements:newElements,appState:appState,commitToHistory:true,});return{success:true,}}else{return{error:true,msg:'element not found',}}}catch(error){return{error:true,msg:JSON.stringify(error),}}},updateElement:(param)=>{try{const existingElements=window.excalidrawAPI.getSceneElements();const resIds=[];for(let i=0;i<param.length;i++){const idx=existingElements.findIndex((e)=>e.id===param[i].id);if(idx>=0){resIds.push[idx];window.excalidrawAPI.mutateElement(existingElements[idx],{...param[i]})}}return{success:true,msg:`已更新元素：${resIds.join(',')}`,}}catch(error){return{error:true,msg:JSON.stringify(error),}}},cleanup:()=>{try{window.excalidrawAPI.resetScene();return{success:true,}}catch(error){return{error:true,msg:JSON.stringify(error),}}},};const handleExecution=(event)=>{const{action,payload,requestId}=event.detail;const param=JSON.parse(payload||'{}');let data,error;try{const handler=eventHandler[action];if(!handler){error='event name not found'}data=handler(param)}catch(e){error=e.message}window.dispatchEvent(new CustomEvent('chrome-mcp:response',{detail:{requestId,data,error}}),)};const initialize=()=>{window.addEventListener('chrome-mcp:execute',handleExecution);window.addEventListener('chrome-mcp:cleanup',cleanup);window[SCRIPT_ID]=true};const cleanup=()=>{window.removeEventListener('chrome-mcp:execute',handleExecution);window.removeEventListener('chrome-mcp:cleanup',cleanup);delete window[SCRIPT_ID];delete window.excalidrawAPI};initialize()})();
```

## Available Commands

### Drawing Commands
- `getSceneElements` - Get current elements
- `addElement` - Add shapes, text, arrows  
- `updateElement` - Modify existing elements
- `deleteElement` - Remove elements
- `cleanup` - Clear canvas

### Element Types
- `rectangle`, `ellipse`, `diamond` - Basic shapes
- `text` - Text labels (can be bound to shapes)
- `arrow`, `line` - Connections between elements
- `frame` - Organize sections

## Color Scheme Guidelines

```json
{
  "frontend": { "bg": "#e8f5e8", "stroke": "#2e7d32" },
  "backend": { "bg": "#e3f2fd", "stroke": "#1976d2" },
  "database": { "bg": "#fff3e0", "stroke": "#f57c00" },
  "external": { "bg": "#fce4ec", "stroke": "#c2185b" },
  "cache": { "bg": "#ffebee", "stroke": "#d32f2f" },
  "queue": { "bg": "#f3e5f5", "stroke": "#7b1fa2" }
}
```

## Example Element Creation

```json
{
  "eventName": "addElement",
  "payload": {
    "eles": [
      {
        "id": "api-server-1",
        "type": "rectangle",
        "x": 100,
        "y": 100,
        "width": 220,
        "height": 80,
        "backgroundColor": "#e3f2fd",
        "strokeColor": "#1976d2",
        "fillStyle": "solid"
      },
      {
        "id": "text-api-1",
        "type": "text",
        "x": 110,
        "y": 125,
        "width": 200,
        "height": 30,
        "text": "API Server",
        "fontSize": 16,
        "textAlign": "center",
        "containerId": "api-server-1"
      }
    ]
  }
}
```

## Best Practices

1. **Always inject script first** into excalidraw.com
2. **Clear canvas** before drawing new diagrams
3. **Use consistent colors** for element categories
4. **Create relationships** between text and shapes using containerId
5. **Bind arrows** to elements using startBinding/endBinding
6. **Plan layout** to avoid overlapping elements
```