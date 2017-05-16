/********************************************************************************
** Form generated from reading UI file 'qrl_leds_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_LEDS_MANAGER_H
#define UI_QRL_LEDS_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QListWidget>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QTabWidget>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_QRL_LedsManager
{
public:
    QGridLayout *gridLayout;
    QListWidget *ledListWidget;
    QTabWidget *tabWidget;
    QWidget *tab;
    QGridLayout *gridLayout1;
    QCheckBox *showCheckBox;
    QSpacerItem *spacerItem;
    QLabel *colorLabel;
    QSpacerItem *spacerItem1;
    QComboBox *ledColorComboBox;
    QSpacerItem *spacerItem2;
    QSpacerItem *spacerItem3;
    QSpacerItem *spacerItem4;
    QPushButton *helpButton;
    QSpacerItem *spacerItem5;
    QPushButton *closeButton;

    void setupUi(QDialog *QRL_LedsManager)
    {
        if (QRL_LedsManager->objectName().isEmpty())
            QRL_LedsManager->setObjectName(QString::fromUtf8("QRL_LedsManager"));
        QRL_LedsManager->resize(303, 228);
        QRL_LedsManager->setMinimumSize(QSize(303, 228));
        QRL_LedsManager->setMaximumSize(QSize(303, 228));
        const QIcon icon = QIcon(QString::fromUtf8(":/icons/led_icon.xpm"));
        QRL_LedsManager->setWindowIcon(icon);
        gridLayout = new QGridLayout(QRL_LedsManager);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        ledListWidget = new QListWidget(QRL_LedsManager);
        ledListWidget->setObjectName(QString::fromUtf8("ledListWidget"));
        ledListWidget->setBaseSize(QSize(100, 0));

        gridLayout->addWidget(ledListWidget, 0, 0, 2, 1);

        tabWidget = new QTabWidget(QRL_LedsManager);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        gridLayout1 = new QGridLayout(tab);
        gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
        showCheckBox = new QCheckBox(tab);
        showCheckBox->setObjectName(QString::fromUtf8("showCheckBox"));

        gridLayout1->addWidget(showCheckBox, 0, 0, 2, 3);

        spacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout1->addItem(spacerItem, 1, 2, 1, 1);

        colorLabel = new QLabel(tab);
        colorLabel->setObjectName(QString::fromUtf8("colorLabel"));

        gridLayout1->addWidget(colorLabel, 2, 0, 1, 1);

        spacerItem1 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout1->addItem(spacerItem1, 2, 1, 1, 2);

        ledColorComboBox = new QComboBox(tab);
        ledColorComboBox->setObjectName(QString::fromUtf8("ledColorComboBox"));

        gridLayout1->addWidget(ledColorComboBox, 3, 0, 1, 1);

        spacerItem2 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout1->addItem(spacerItem2, 3, 1, 1, 2);

        spacerItem3 = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout1->addItem(spacerItem3, 4, 0, 1, 1);

        tabWidget->addTab(tab, QString());

        gridLayout->addWidget(tabWidget, 0, 1, 1, 4);

        spacerItem4 = new QSpacerItem(16, 27, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout->addItem(spacerItem4, 1, 1, 1, 1);

        helpButton = new QPushButton(QRL_LedsManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));

        gridLayout->addWidget(helpButton, 1, 2, 1, 1);

        spacerItem5 = new QSpacerItem(16, 27, QSizePolicy::Expanding, QSizePolicy::Minimum);

        gridLayout->addItem(spacerItem5, 1, 3, 1, 1);

        closeButton = new QPushButton(QRL_LedsManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));

        gridLayout->addWidget(closeButton, 1, 4, 1, 1);


        retranslateUi(QRL_LedsManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_LedsManager, SLOT(hide()));

        tabWidget->setCurrentIndex(0);


        QMetaObject::connectSlotsByName(QRL_LedsManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_LedsManager)
    {
        QRL_LedsManager->setWindowTitle(QApplication::translate("QRL_LedsManager", "Leds Manager", 0, QApplication::UnicodeUTF8));
        showCheckBox->setText(QApplication::translate("QRL_LedsManager", "Show/Hide", 0, QApplication::UnicodeUTF8));
        colorLabel->setText(QApplication::translate("QRL_LedsManager", "Led color", 0, QApplication::UnicodeUTF8));
        ledColorComboBox->clear();
        ledColorComboBox->insertItems(0, QStringList()
         << QApplication::translate("QRL_LedsManager", "Red", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LedsManager", "Green", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LedsManager", "Blue", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("QRL_LedsManager", "Yellow", 0, QApplication::UnicodeUTF8)
        );
        tabWidget->setTabText(tabWidget->indexOf(tab), QApplication::translate("QRL_LedsManager", "Led", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_LedsManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_LedsManager", "close", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_LedsManager: public Ui_QRL_LedsManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_LEDS_MANAGER_H
