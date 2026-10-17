import XCTest

final class PhotoPermissionTests: XCTestCase {
    func testPhotoAccessButtonPresentsSystemPermissionAndUpdatesState() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let request = app.buttons["Permitir acceso a Fotos"]
        XCTAssertTrue(request.waitForExistence(timeout: 15), app.debugDescription)
        request.tap()

        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = system.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 15),
                      "El botón no presentó el permiso. App: \(app.debugDescription) Sistema: \(system.debugDescription)")
        let allow = alert.buttons.matching(NSPredicate(
            format: "label IN %@", ["Allow Full Access", "Allow Access to All Photos", "Permitir acceso completo", "Permitir acceso a todas las fotos"])).firstMatch
        XCTAssertTrue(allow.waitForExistence(timeout: 5), system.debugDescription)
        allow.tap()
        XCTAssertTrue(app.staticTexts["Acceso: completo"].waitForExistence(timeout: 15), app.debugDescription)
    }
}
