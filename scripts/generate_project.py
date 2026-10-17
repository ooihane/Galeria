#!/usr/bin/env python3
"""Generate a dependency-free Xcode project. Requires Python 3, not XcodeGen."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[1]
def uid(name):
    return hashlib.sha256(name.encode()).hexdigest()[:24].upper()

def generate():
    files = sorted((ROOT / 'Galeria').glob('*.swift'))
    objects = []
    def obj(name, body):
        objects.append(f'{uid(name)} = {{ {body} }};')
    refs, builds = [], []
    for file in files:
        ref, build = 'ref:' + file.name, 'build:' + file.name
        obj(ref, f'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file.name}; sourceTree = "<group>";')
        obj(build, f'isa = PBXBuildFile; fileRef = {uid(ref)};')
        refs.append(uid(ref)); builds.append(uid(build))
    obj('app', 'isa = PBXFileReference; explicitFileType = wrapper.application; path = Galeria.app; sourceTree = BUILT_PRODUCTS_DIR;')
    obj('sourceGroup', f'isa = PBXGroup; children = ({",".join(refs)},); path = Galeria; sourceTree = "<group>";')
    obj('products', f'isa = PBXGroup; children = ({uid("app")},{uid("uiProduct")},); name = Products; sourceTree = "<group>";')
    obj('uiRef', 'isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PhotoPermissionTests.swift; sourceTree = "<group>";')
    obj('uiBuild', f'isa = PBXBuildFile; fileRef = {uid("uiRef")};')
    obj('uiGroup', f'isa = PBXGroup; children = ({uid("uiRef")},); path = GaleriaUITests; sourceTree = "<group>";')
    obj('uiProduct', 'isa = PBXFileReference; explicitFileType = wrapper.cfbundle; path = GaleriaUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;')
    obj('uiSources', f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({uid("uiBuild")},); runOnlyForDeploymentPostprocessing = 0;')
    obj('uiProxy', f'isa = PBXContainerItemProxy; containerPortal = {uid("project")}; proxyType = 1; remoteGlobalIDString = {uid("target")}; remoteInfo = Galeria;')
    obj('uiDependency', f'isa = PBXTargetDependency; target = {uid("target")}; targetProxy = {uid("uiProxy")};')
    for mode in ['Debug', 'Release']:
        obj('ui' + mode, f'isa = XCBuildConfiguration; buildSettings = {{ PRODUCT_NAME = GaleriaUITests; PRODUCT_BUNDLE_IDENTIFIER = com.galeria.personal.uitests; GENERATE_INFOPLIST_FILE = YES; TEST_TARGET_NAME = Galeria; TARGETED_DEVICE_FAMILY = 1; SWIFT_VERSION = 5.0; CODE_SIGN_STYLE = Automatic; }}; name = {mode};')
    obj('uiConfigs', f'isa = XCConfigurationList; buildConfigurations = ({uid("uiDebug")},{uid("uiRelease")},); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
    obj('uiTarget', f'isa = PBXNativeTarget; buildConfigurationList = {uid("uiConfigs")}; buildPhases = ({uid("uiSources")},); buildRules = (); dependencies = ({uid("uiDependency")},); name = GaleriaUITests; productName = GaleriaUITests; productReference = {uid("uiProduct")}; productType = "com.apple.product-type.bundle.ui-testing";')
    obj('rootGroup', f'isa = PBXGroup; children = ({uid("sourceGroup")},{uid("uiGroup")},{uid("products")},); sourceTree = "<group>";')
    obj('sources', f'isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(builds)},); runOnlyForDeploymentPostprocessing = 0;')
    obj('frameworks', 'isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
    obj('resources', 'isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0;')
    for mode in ['Debug', 'Release']:
        obj('project' + mode, f'isa = XCBuildConfiguration; buildSettings = {{ SDKROOT = iphoneos; IPHONEOS_DEPLOYMENT_TARGET = 17.0; CLANG_ENABLE_MODULES = YES; SWIFT_VERSION = 5.0; }}; name = {mode};')
        opt = '-Onone' if mode == 'Debug' else '-O'
        obj('target' + mode, f'''isa = XCBuildConfiguration; buildSettings = {{
            PRODUCT_NAME = Galeria;
            PRODUCT_BUNDLE_IDENTIFIER = com.galeria.personal;
            GENERATE_INFOPLIST_FILE = YES;
            INFOPLIST_KEY_CFBundleDisplayName = "Galería";
            INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "Galería necesita acceder a tus fotos para mostrar tu biblioteca y comprobar álbumes y favoritos. El análisis se realiza en el dispositivo.";
            INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
            INFOPLIST_KEY_UILaunchScreen_Generation = YES;
            INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
            TARGETED_DEVICE_FAMILY = 1;
            MARKETING_VERSION = 0.1.0;
            CURRENT_PROJECT_VERSION = 1;
            SWIFT_VERSION = 5.0;
            SWIFT_OPTIMIZATION_LEVEL = "{opt}";
            CODE_SIGN_STYLE = Automatic;
            LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
        }}; name = {mode};''')
    for kind in ['project', 'target']:
        obj(kind + 'Configs', f'isa = XCConfigurationList; buildConfigurations = ({uid(kind+"Debug")},{uid(kind+"Release")},); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;')
    obj('target', f'isa = PBXNativeTarget; buildConfigurationList = {uid("targetConfigs")}; buildPhases = ({uid("sources")},{uid("frameworks")},{uid("resources")},); buildRules = (); dependencies = (); name = Galeria; productName = Galeria; productReference = {uid("app")}; productType = "com.apple.product-type.application";')
    obj('project', f'isa = PBXProject; attributes = {{ LastUpgradeCheck = 1600; }}; buildConfigurationList = {uid("projectConfigs")}; compatibilityVersion = "Xcode 14.0"; developmentRegion = es; hasScannedForEncodings = 0; knownRegions = (es, Base,); mainGroup = {uid("rootGroup")}; productRefGroup = {uid("products")}; projectDirPath = ""; projectRoot = ""; targets = ({uid("target")},{uid("uiTarget")},);')
    project = ROOT / 'Galeria.xcodeproj'
    project.mkdir(exist_ok=True)
    (project / 'project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n' + '\n'.join(objects) + f'\n}}; rootObject = {uid("project")}; }}\n')
    schemes = project / 'xcshareddata' / 'xcschemes'
    schemes.mkdir(parents=True, exist_ok=True)
    (schemes / 'Galeria.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
 <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
  <BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
   <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid('target')}" BuildableName="Galeria.app" BlueprintName="Galeria" ReferencedContainer="container:Galeria.xcodeproj"/>
  </BuildActionEntry>
  <BuildActionEntry buildForTesting="YES" buildForRunning="NO" buildForProfiling="NO" buildForArchiving="NO" buildForAnalyzing="NO">
   <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid('uiTarget')}" BuildableName="GaleriaUITests.xctest" BlueprintName="GaleriaUITests" ReferencedContainer="container:Galeria.xcodeproj"/>
  </BuildActionEntry></BuildActionEntries>
 </BuildAction>
 <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
  <Testables><TestableReference skipped="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid('uiTarget')}" BuildableName="GaleriaUITests.xctest" BlueprintName="GaleriaUITests" ReferencedContainer="container:Galeria.xcodeproj"/></TestableReference></Testables>
 </TestAction>
 <LaunchAction buildConfiguration="Debug" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugServiceExtension="internal" allowLocationSimulation="YES">
  <BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid('target')}" BuildableName="Galeria.app" BlueprintName="Galeria" ReferencedContainer="container:Galeria.xcodeproj"/></BuildableProductRunnable>
 </LaunchAction>
 <AnalyzeAction buildConfiguration="Debug"/>
 <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')

if __name__ == '__main__':
    generate()
