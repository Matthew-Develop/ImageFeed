//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Matthew on 13.04.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        sleep(1)
    }
    
    func testAuth() throws {
        //Нажатие на кнопку авторизации и переход к Web View
        let buttonAuth = app.buttons["Authenticate"]
        buttonAuth.tap()
        
        sleep(1)
        let authWebView = app.webViews["AuthWebView"]
        
        //Ожидание появления Web View
        XCTAssertTrue(authWebView.waitForExistence(timeout: 5))
        
        //Нахождение полей ввода логина и пароля. Ввод личной информации
        let loginTextField = authWebView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
    
        loginTextField.tap()
        loginTextField.typeText("email")
        loginTextField.swipeUp()

        let passwordTextField = authWebView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("pass")
        passwordTextField.swipeUp()
        
        //Нажатие на кнопку логин
        let webViewLoginButton = authWebView.descendants(matching: .button).element
        XCTAssertTrue(webViewLoginButton.waitForExistence(timeout: 3))
        webViewLoginButton.tap()
        
        print(app.debugDescription)
        
        //Ожидание прогрузки ленты фотографий
        sleep(5)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables.element
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        let likeButton = cell.buttons["CellLikeButton"]
        
        // Поставить лайк в ячейке верхней картинки
        sleep(2)
        likeButton.tap()

        // Отменить лайк в ячейке верхней картинки
        sleep(10)
        likeButton.tap()
        
        //Скроллинг вниз - вверх
        sleep(4)
        app.swipeUp()
        sleep(4)
        app.swipeDown()
        app.swipeDown()
        
        // Нажать на верхнюю ячейку
        sleep(2)
        cell.tap()
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        let likeButtonSingleImage = app.buttons["SingleImageLikeButton"]
        
        // Поставить лайк Single Image
        sleep(2)
        likeButtonSingleImage.tap()

        // Отменить лайк Single image
        sleep(10)
        likeButtonSingleImage.tap()
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        // Уменьшить картинку
        sleep(3)
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        sleep(2)
        app.buttons["SingleImageBackButton"].tap()
    }
    
    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["name"].exists)
        XCTAssertTrue(app.staticTexts["@nickname"].exists)
        XCTAssertTrue(app.staticTexts["bio"].exists)
        XCTAssertTrue(app.staticTexts["Избранное"].exists)
        
        // Нажать кнопку логаута
        let logoutButton = app.buttons["LogoutButton"]
        logoutButton.tap()
        
        // Проверить, что открылся экран авторизации
        XCTAssertTrue(app.alerts["Пока, пока!"].waitForExistence(timeout: 3))
        sleep(1)
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
