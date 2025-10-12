#include "ThemeManager.h"

ThemeManager::ThemeManager(QObject *parent) : QObject(parent), m_darkMode(true)
{
    updateColors();
}

void ThemeManager::setDarkMode(bool enabled)
{
    if (m_darkMode != enabled) {
        m_darkMode = enabled;
        updateColors();
        emit darkModeChanged();
    }
}

void ThemeManager::updateColors()
{
    QVariantMap textColors;
    QVariantMap backgroundColors;
    QVariantMap accentColors;

    if (m_darkMode) {
        // Dark Mode
        textColors["primary"] = QColor("#FFFFFF");
        textColors["secondary"] = QColor("#AAAAAA");
        backgroundColors["main"] = QColor("#303030");
        backgroundColors["card"] = QColor("#181818");
        accentColors["primary"] = QColor("#8c8c8c");
        accentColors["error"] = QColor("#FF5E5E");
    } else {
        // Light Mode
        textColors["primary"] = QColor("#000000");
        textColors["secondary"] = QColor("#555555");
        backgroundColors["main"] = QColor("#FFFFFF");
        backgroundColors["card"] = QColor("#F2F2F2");
        accentColors["primary"] = QColor("#8c8c8c");
        accentColors["error"] = QColor("#FF3B30");
    }

    QVariantMap colors;
    colors["text"] = textColors;
    colors["background"] = backgroundColors;
    colors["accent"] = accentColors;

    m_colors = colors;
    emit colorsChanged();
}
