with open('lib/screens/shared/product_card_widget.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}''', '''                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}''')

with open('lib/screens/shared/product_card_widget.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
