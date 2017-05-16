/********************************************************************************
** Form generated from reading UI file 'qrl_parameters_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_PARAMETERS_MANAGER_H
#define UI_QRL_PARAMETERS_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QGroupBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QListWidget>
#include <QtGui/QPushButton>
#include <QtGui/QRadioButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QTabWidget>
#include <QtGui/QTableWidget>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_QRL_ParametersManager
{
public:
    QGridLayout *gridLayout;
    QListWidget *blockListWidget;
    QCheckBox *batchCheckBox;
    QPushButton *downloadPushButton;
    QPushButton *uploadPushButton;
    QHBoxLayout *hboxLayout;
    QSpacerItem *spacerItem;
    QPushButton *helpButton;
    QSpacerItem *spacerItem1;
    QPushButton *closeButton;
    QSpacerItem *spacerItem2;
    QTabWidget *tabWidget;
    QWidget *tab;
    QGridLayout *gridLayout1;
    QTableWidget *parameterTableWidget;
    QWidget *Options;
    QGridLayout *gridLayout_2;
    QGroupBox *groupBox;
    QGridLayout *gridLayout2;
    QLineEdit *paramLineEdit;
    QRadioButton *hideRadioButton;
    QRadioButton *showRadioButton;
    QRadioButton *fineRadioButton;
    QPushButton *savePushButton;
    QPushButton *loadPushButton;
    QLabel *label;

    void setupUi(QDialog *QRL_ParametersManager)
    {
        if (QRL_ParametersManager->objectName().isEmpty())
            QRL_ParametersManager->setObjectName(QString::fromUtf8("QRL_ParametersManager"));
        QRL_ParametersManager->resize(607, 367);
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/parameters_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        QRL_ParametersManager->setWindowIcon(icon);
        gridLayout = new QGridLayout(QRL_ParametersManager);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        blockListWidget = new QListWidget(QRL_ParametersManager);
        blockListWidget->setObjectName(QString::fromUtf8("blockListWidget"));
        blockListWidget->setMinimumSize(QSize(200, 0));
        blockListWidget->setBaseSize(QSize(100, 0));

        gridLayout->addWidget(blockListWidget, 0, 0, 4, 1);

        batchCheckBox = new QCheckBox(QRL_ParametersManager);
        batchCheckBox->setObjectName(QString::fromUtf8("batchCheckBox"));

        gridLayout->addWidget(batchCheckBox, 1, 1, 1, 1);

        downloadPushButton = new QPushButton(QRL_ParametersManager);
        downloadPushButton->setObjectName(QString::fromUtf8("downloadPushButton"));
        downloadPushButton->setEnabled(false);

        gridLayout->addWidget(downloadPushButton, 1, 2, 1, 1);

        uploadPushButton = new QPushButton(QRL_ParametersManager);
        uploadPushButton->setObjectName(QString::fromUtf8("uploadPushButton"));
        uploadPushButton->setEnabled(true);

        gridLayout->addWidget(uploadPushButton, 1, 3, 1, 1);

        hboxLayout = new QHBoxLayout();
        hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
        spacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem);

        helpButton = new QPushButton(QRL_ParametersManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));

        hboxLayout->addWidget(helpButton);

        spacerItem1 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem1);

        closeButton = new QPushButton(QRL_ParametersManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));

        hboxLayout->addWidget(closeButton);

        spacerItem2 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout->addItem(spacerItem2);


        gridLayout->addLayout(hboxLayout, 2, 1, 2, 3);

        tabWidget = new QTabWidget(QRL_ParametersManager);
        tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        gridLayout1 = new QGridLayout(tab);
        gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
        parameterTableWidget = new QTableWidget(tab);
        parameterTableWidget->setObjectName(QString::fromUtf8("parameterTableWidget"));

        gridLayout1->addWidget(parameterTableWidget, 0, 0, 1, 1);

        tabWidget->addTab(tab, QString());
        Options = new QWidget();
        Options->setObjectName(QString::fromUtf8("Options"));
        gridLayout_2 = new QGridLayout(Options);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        groupBox = new QGroupBox(Options);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        gridLayout2 = new QGridLayout(groupBox);
        gridLayout2->setObjectName(QString::fromUtf8("gridLayout2"));
        paramLineEdit = new QLineEdit(groupBox);
        paramLineEdit->setObjectName(QString::fromUtf8("paramLineEdit"));

        gridLayout2->addWidget(paramLineEdit, 1, 0, 1, 1);

        hideRadioButton = new QRadioButton(groupBox);
        hideRadioButton->setObjectName(QString::fromUtf8("hideRadioButton"));

        gridLayout2->addWidget(hideRadioButton, 2, 0, 1, 1);

        showRadioButton = new QRadioButton(groupBox);
        showRadioButton->setObjectName(QString::fromUtf8("showRadioButton"));

        gridLayout2->addWidget(showRadioButton, 3, 0, 1, 1);

        fineRadioButton = new QRadioButton(groupBox);
        fineRadioButton->setObjectName(QString::fromUtf8("fineRadioButton"));
        fineRadioButton->setChecked(true);

        gridLayout2->addWidget(fineRadioButton, 4, 0, 1, 1);

        savePushButton = new QPushButton(groupBox);
        savePushButton->setObjectName(QString::fromUtf8("savePushButton"));

        gridLayout2->addWidget(savePushButton, 5, 0, 1, 1);

        loadPushButton = new QPushButton(groupBox);
        loadPushButton->setObjectName(QString::fromUtf8("loadPushButton"));
        loadPushButton->setEnabled(true);

        gridLayout2->addWidget(loadPushButton, 6, 0, 1, 1);

        label = new QLabel(groupBox);
        label->setObjectName(QString::fromUtf8("label"));

        gridLayout2->addWidget(label, 0, 0, 1, 1);


        gridLayout_2->addWidget(groupBox, 0, 0, 1, 1);

        tabWidget->addTab(Options, QString());

        gridLayout->addWidget(tabWidget, 0, 1, 1, 3);

        blockListWidget->raise();
        batchCheckBox->raise();
        downloadPushButton->raise();
        uploadPushButton->raise();
        tabWidget->raise();

        retranslateUi(QRL_ParametersManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_ParametersManager, SLOT(hide()));

        tabWidget->setCurrentIndex(1);


        QMetaObject::connectSlotsByName(QRL_ParametersManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_ParametersManager)
    {
        QRL_ParametersManager->setWindowTitle(QApplication::translate("QRL_ParametersManager", "Parameters Manager", 0, QApplication::UnicodeUTF8));
        batchCheckBox->setText(QApplication::translate("QRL_ParametersManager", "batch mode", 0, QApplication::UnicodeUTF8));
        downloadPushButton->setText(QApplication::translate("QRL_ParametersManager", "download", 0, QApplication::UnicodeUTF8));
        uploadPushButton->setText(QApplication::translate("QRL_ParametersManager", "upload", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_ParametersManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_ParametersManager", "Close Manager", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(tab), QApplication::translate("QRL_ParametersManager", "Block Parameters", 0, QApplication::UnicodeUTF8));
        groupBox->setTitle(QApplication::translate("QRL_ParametersManager", "Blocks containing", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        paramLineEdit->setToolTip(QString());
#endif // QT_NO_TOOLTIP
        paramLineEdit->setText(QApplication::translate("QRL_ParametersManager", "IPARAM RPARAM", 0, QApplication::UnicodeUTF8));
        hideRadioButton->setText(QApplication::translate("QRL_ParametersManager", "should hide", 0, QApplication::UnicodeUTF8));
        showRadioButton->setText(QApplication::translate("QRL_ParametersManager", "should only visible", 0, QApplication::UnicodeUTF8));
        fineRadioButton->setText(QApplication::translate("QRL_ParametersManager", "are fine (Show all Parameter)", 0, QApplication::UnicodeUTF8));
        savePushButton->setText(QApplication::translate("QRL_ParametersManager", "Save Parameter", 0, QApplication::UnicodeUTF8));
        loadPushButton->setText(QApplication::translate("QRL_ParametersManager", "Load Parameter", 0, QApplication::UnicodeUTF8));
        label->setText(QApplication::translate("QRL_ParametersManager", "(seperate different string with space)", 0, QApplication::UnicodeUTF8));
        tabWidget->setTabText(tabWidget->indexOf(Options), QApplication::translate("QRL_ParametersManager", "Options", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_ParametersManager: public Ui_QRL_ParametersManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_PARAMETERS_MANAGER_H
