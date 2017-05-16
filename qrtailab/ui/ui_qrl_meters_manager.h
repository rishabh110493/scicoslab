/********************************************************************************
** Form generated from reading UI file 'qrl_meters_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_METERS_MANAGER_H
#define UI_QRL_METERS_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QListWidget>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QTabWidget>
#include <QtGui/QWidget>
#include "qwt_counter.h"

QT_BEGIN_NAMESPACE

class Ui_QRL_MetersManager
{
public:
    QGridLayout *gridLayout;
    QHBoxLayout *hboxLayout;
    QSpacerItem *spacerItem;
    QPushButton *helpButton;
    QSpacerItem *spacerItem1;
    QPushButton *closeButton;
    QSpacerItem *spacerItem2;
    QListWidget *meterListWidget;
    QTabWidget *tabWidget;
    QWidget *tab;
    QGridLayout *gridLayout1;
    QCheckBox *showCheckBox;
    QLabel *frameLabel;
    QwtCounter *rrCounter;
    QLabel *minLabel;
    QwtCounter *minCounter;
    QLabel *maxLabel;
    QwtCounter *maxCounter;
    QComboBox *meterComboBox;
    QSpacerItem *spacerItem3;
    QWidget *ThermoOptions;
    QPushButton *thermoColor1PushButton;
    QComboBox *directionComboBox;
    QLabel *label;
    QwtCounter *pipeWithCounter;
    QPushButton *thermoColor2PushButton;
    QComboBox *colorComboBox;
    QCheckBox *alarmCheckBox;
    QwtCounter *alarmLevelCounter;
    QLabel *label_3;
    QPushButton *alarmThermoColor1PushButton;
    QPushButton *alarmThermoColor2PushButton;
    QWidget *DialOptions;
    QPushButton *dialColorPushButton;
    QWidget *LcdOptions;
    QPushButton *fontPushButton;
    QComboBox *formatComboBox;
    QLabel *label_4;
    QwtCounter *precisionCounter;

    void setupUi(QDialog *QRL_MetersManager)
    {
        if (QRL_MetersManager->objectName().isEmpty())
            QRL_MetersManager->setObjectName(QString::fromUtf8("QRL_MetersManager"));
        QRL_MetersManager->resize(400, 277);
        QRL_MetersManager->setMinimumSize(QSize(400, 277));
        QRL_MetersManager->setMaximumSize(QSize(400, 277));
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/meter_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        QRL_MetersManager->setWindowIcon(icon);
        gridLayout = new QGridLayout(QRL_MetersManager);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        hboxLayout = new QHBoxLayout();
        hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
        spacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem);

        helpButton = new QPushButton(QRL_MetersManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));

        hboxLayout->addWidget(helpButton);

        spacerItem1 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem1);

        closeButton = new QPushButton(QRL_MetersManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));

        hboxLayout->addWidget(closeButton);

        spacerItem2 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem2);


        gridLayout->addLayout(hboxLayout, 1, 1, 1, 1);

        meterListWidget = new QListWidget(QRL_MetersManager);
        meterListWidget->setObjectName(QString::fromUtf8("meterListWidget"));
        meterListWidget->setBaseSize(QSize(100, 0));

        gridLayout->addWidget(meterListWidget, 0, 0, 2, 1);

        tabWidget = new QTabWidget(QRL_MetersManager);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        gridLayout1 = new QGridLayout(tab);
        gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
        showCheckBox = new QCheckBox(tab);
        showCheckBox->setObjectName(QString::fromUtf8("showCheckBox"));

        gridLayout1->addWidget(showCheckBox, 0, 0, 1, 3);

        frameLabel = new QLabel(tab);
        frameLabel->setObjectName(QString::fromUtf8("frameLabel"));

        gridLayout1->addWidget(frameLabel, 1, 0, 1, 2);

        rrCounter = new QwtCounter(tab);
        rrCounter->setObjectName(QString::fromUtf8("rrCounter"));
        rrCounter->setNumButtons(1);
        rrCounter->setProperty("basicstep", QVariant(0.1));
        rrCounter->setMinValue(0.1);
        rrCounter->setMaxValue(1e+07);
        rrCounter->setValue(20);

        gridLayout1->addWidget(rrCounter, 1, 2, 1, 1);

        minLabel = new QLabel(tab);
        minLabel->setObjectName(QString::fromUtf8("minLabel"));

        gridLayout1->addWidget(minLabel, 2, 0, 1, 1);

        minCounter = new QwtCounter(tab);
        minCounter->setObjectName(QString::fromUtf8("minCounter"));
        minCounter->setNumButtons(0);
        minCounter->setProperty("basicstep", QVariant(0.5));
        minCounter->setMinValue(-2.14748e+09);
        minCounter->setMaxValue(2.14748e+09);
        minCounter->setStepButton1(10);
        minCounter->setStepButton2(100);
        minCounter->setStepButton3(1000);
        minCounter->setValue(-1);

        gridLayout1->addWidget(minCounter, 2, 1, 1, 2);

        maxLabel = new QLabel(tab);
        maxLabel->setObjectName(QString::fromUtf8("maxLabel"));

        gridLayout1->addWidget(maxLabel, 3, 0, 1, 1);

        maxCounter = new QwtCounter(tab);
        maxCounter->setObjectName(QString::fromUtf8("maxCounter"));
        maxCounter->setNumButtons(0);
        maxCounter->setProperty("basicstep", QVariant(0.5));
        maxCounter->setMinValue(-2.14748e+09);
        maxCounter->setMaxValue(2.14748e+09);
        maxCounter->setStepButton1(10);
        maxCounter->setStepButton2(100);
        maxCounter->setStepButton3(1000);
        maxCounter->setValue(1);

        gridLayout1->addWidget(maxCounter, 3, 1, 1, 2);

        meterComboBox = new QComboBox(tab);
        meterComboBox->setObjectName(QString::fromUtf8("meterComboBox"));

        gridLayout1->addWidget(meterComboBox, 4, 0, 1, 3);

        spacerItem3 = new QSpacerItem(207, 21, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout1->addItem(spacerItem3, 5, 0, 1, 3);

        tabWidget->addTab(tab, QString());
        ThermoOptions = new QWidget();
        ThermoOptions->setObjectName(QString::fromUtf8("ThermoOptions"));
        thermoColor1PushButton = new QPushButton(ThermoOptions);
        thermoColor1PushButton->setObjectName(QString::fromUtf8("thermoColor1PushButton"));
        thermoColor1PushButton->setGeometry(QRect(10, 50, 83, 27));
        directionComboBox = new QComboBox(ThermoOptions);
        directionComboBox->setObjectName(QString::fromUtf8("directionComboBox"));
        directionComboBox->setEnabled(false);
        directionComboBox->setGeometry(QRect(10, 20, 72, 22));
        label = new QLabel(ThermoOptions);
        label->setObjectName(QString::fromUtf8("label"));
        label->setGeometry(QRect(20, 90, 57, 18));
        pipeWithCounter = new QwtCounter(ThermoOptions);
        pipeWithCounter->setObjectName(QString::fromUtf8("pipeWithCounter"));
        pipeWithCounter->setGeometry(QRect(100, 90, 74, 23));
        pipeWithCounter->setNumButtons(0);
        pipeWithCounter->setProperty("basicstep", QVariant(1));
        pipeWithCounter->setMinValue(1);
        pipeWithCounter->setMaxValue(1000);
        pipeWithCounter->setValue(14);
        thermoColor2PushButton = new QPushButton(ThermoOptions);
        thermoColor2PushButton->setObjectName(QString::fromUtf8("thermoColor2PushButton"));
        thermoColor2PushButton->setEnabled(true);
        thermoColor2PushButton->setGeometry(QRect(100, 50, 83, 27));
        colorComboBox = new QComboBox(ThermoOptions);
        colorComboBox->setObjectName(QString::fromUtf8("colorComboBox"));
        colorComboBox->setGeometry(QRect(90, 20, 121, 22));
        alarmCheckBox = new QCheckBox(ThermoOptions);
        alarmCheckBox->setObjectName(QString::fromUtf8("alarmCheckBox"));
        alarmCheckBox->setGeometry(QRect(20, 120, 83, 22));
        alarmLevelCounter = new QwtCounter(ThermoOptions);
        alarmLevelCounter->setObjectName(QString::fromUtf8("alarmLevelCounter"));
        alarmLevelCounter->setEnabled(true);
        alarmLevelCounter->setGeometry(QRect(140, 120, 74, 23));
        alarmLevelCounter->setNumButtons(0);
        alarmLevelCounter->setProperty("basicstep", QVariant(0.001));
        alarmLevelCounter->setMinValue(-1e+06);
        alarmLevelCounter->setMaxValue(1e+06);
        alarmLevelCounter->setValue(1);
        label_3 = new QLabel(ThermoOptions);
        label_3->setObjectName(QString::fromUtf8("label_3"));
        label_3->setGeometry(QRect(90, 120, 31, 18));
        alarmThermoColor1PushButton = new QPushButton(ThermoOptions);
        alarmThermoColor1PushButton->setObjectName(QString::fromUtf8("alarmThermoColor1PushButton"));
        alarmThermoColor1PushButton->setEnabled(true);
        alarmThermoColor1PushButton->setGeometry(QRect(10, 150, 83, 27));
        alarmThermoColor2PushButton = new QPushButton(ThermoOptions);
        alarmThermoColor2PushButton->setObjectName(QString::fromUtf8("alarmThermoColor2PushButton"));
        alarmThermoColor2PushButton->setEnabled(true);
        alarmThermoColor2PushButton->setGeometry(QRect(120, 150, 83, 27));
        tabWidget->addTab(ThermoOptions, QString());
        DialOptions = new QWidget();
        DialOptions->setObjectName(QString::fromUtf8("DialOptions"));
        dialColorPushButton = new QPushButton(DialOptions);
        dialColorPushButton->setObjectName(QString::fromUtf8("dialColorPushButton"));
        dialColorPushButton->setGeometry(QRect(60, 50, 111, 27));
        tabWidget->addTab(DialOptions, QString());
        LcdOptions = new QWidget();
        LcdOptions->setObjectName(QString::fromUtf8("LcdOptions"));
        fontPushButton = new QPushButton(LcdOptions);
        fontPushButton->setObjectName(QString::fromUtf8("fontPushButton"));
        fontPushButton->setGeometry(QRect(50, 100, 111, 31));
        formatComboBox = new QComboBox(LcdOptions);
        formatComboBox->setObjectName(QString::fromUtf8("formatComboBox"));
        formatComboBox->setGeometry(QRect(10, 10, 191, 29));
        label_4 = new QLabel(LcdOptions);
        label_4->setObjectName(QString::fromUtf8("label_4"));
        label_4->setGeometry(QRect(10, 60, 69, 20));
        precisionCounter = new QwtCounter(LcdOptions);
        precisionCounter->setObjectName(QString::fromUtf8("precisionCounter"));
        precisionCounter->setGeometry(QRect(90, 50, 84, 30));
        precisionCounter->setNumButtons(0);
        precisionCounter->setProperty("basicstep", QVariant(1));
        precisionCounter->setMinValue(-1);
        precisionCounter->setMaxValue(100);
        precisionCounter->setValue(4);
        tabWidget->addTab(LcdOptions, QString());

        gridLayout->addWidget(tabWidget, 0, 1, 1, 1);

        QWidget::setTabOrder(meterListWidget, tabWidget);
        QWidget::setTabOrder(tabWidget, pipeWithCounter);
        QWidget::setTabOrder(pipeWithCounter, alarmLevelCounter);
        QWidget::setTabOrder(alarmLevelCounter, colorComboBox);
        QWidget::setTabOrder(colorComboBox, thermoColor1PushButton);
        QWidget::setTabOrder(thermoColor1PushButton, thermoColor2PushButton);
        QWidget::setTabOrder(thermoColor2PushButton, alarmThermoColor1PushButton);
        QWidget::setTabOrder(alarmThermoColor1PushButton, alarmThermoColor2PushButton);
        QWidget::setTabOrder(alarmThermoColor2PushButton, directionComboBox);
        QWidget::setTabOrder(directionComboBox, closeButton);
        QWidget::setTabOrder(closeButton, alarmCheckBox);
        QWidget::setTabOrder(alarmCheckBox, helpButton);
        QWidget::setTabOrder(helpButton, minCounter);
        QWidget::setTabOrder(minCounter, showCheckBox);
        QWidget::setTabOrder(showCheckBox, rrCounter);
        QWidget::setTabOrder(rrCounter, maxCounter);
        QWidget::setTabOrder(maxCounter, meterComboBox);

        retranslateUi(QRL_MetersManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_MetersManager, SLOT(hide()));

        tabWidget->setCurrentIndex(0);
        formatComboBox->setCurrentIndex(1);


        QMetaObject::connectSlotsByName(QRL_MetersManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_MetersManager)
    {
        QRL_MetersManager->setWindowTitle(QApplication::translate("QRL_MetersManager", "Meters Manager", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_MetersManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_MetersManager", "Close Manager", 0, QApplication::UnicodeUTF8));
        showCheckBox->setText(QApplication::translate("QRL_MetersManager", "Show/Hide", 0, QApplication::UnicodeUTF8));
        frameLabel->setText(QApplication::translate("QRL_MetersManager", "Refresh rate", 0, QApplication::UnicodeUTF8));
        minLabel->setText(QApplication::translate("QRL_MetersManager", "Min:", 0, QApplication::UnicodeUTF8));
        maxLabel->setText(QApplication::translate("QRL_MetersManager", "Max:", 0, QApplication::UnicodeUTF8));
        meterComboBox->clear();
        meterComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_MetersManager", "Thermo", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "Dial", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "LCD", 0, QApplication::UnicodeUTF8)
        );
        tabWidget->setTabText(tabWidget->indexOf(tab), QApplication::translate("QRL_MetersManager", "Meter", 0, QApplication::UnicodeUTF8));
        thermoColor1PushButton->setText(QApplication::translate("QRL_MetersManager", "BarColor", 0, QApplication::UnicodeUTF8));
        directionComboBox->clear();
        directionComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_MetersManager", "vertical", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "horizontal", 0, QApplication::UnicodeUTF8)
        );
        label->setText(QApplication::translate("QRL_MetersManager", "pipeWith", 0, QApplication::UnicodeUTF8));
        thermoColor2PushButton->setText(QApplication::translate("QRL_MetersManager", "BarColor", 0, QApplication::UnicodeUTF8));
        colorComboBox->clear();
        colorComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_MetersManager", "LinearGradient", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "Color", 0, QApplication::UnicodeUTF8)
        );
        alarmCheckBox->setText(QApplication::translate("QRL_MetersManager", "alarm", 0, QApplication::UnicodeUTF8));
        label_3->setText(QApplication::translate("QRL_MetersManager", "level", 0, QApplication::UnicodeUTF8));
        alarmThermoColor1PushButton->setText(QApplication::translate("QRL_MetersManager", "BarColor", 0, QApplication::UnicodeUTF8));
        alarmThermoColor2PushButton->setText(QApplication::translate("QRL_MetersManager", "BarColor", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(ThermoOptions), QApplication::translate("QRL_MetersManager", "Options", 0, QApplication::UnicodeUTF8));
        dialColorPushButton->setText(QApplication::translate("QRL_MetersManager", "needle color", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(DialOptions), QApplication::translate("QRL_MetersManager", "Options", 0, QApplication::UnicodeUTF8));
        fontPushButton->setText(QApplication::translate("QRL_MetersManager", "Change Fonts", 0, QApplication::UnicodeUTF8));
        formatComboBox->clear();
        formatComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_MetersManager", " e - exp. format", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "f - fixed format", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_MetersManager", "g - mixed format", 0, QApplication::UnicodeUTF8)
        );
        label_4->setText(QApplication::translate("QRL_MetersManager", "Precision:", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(LcdOptions), QApplication::translate("QRL_MetersManager", "Options", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_MetersManager: public Ui_QRL_MetersManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_METERS_MANAGER_H
